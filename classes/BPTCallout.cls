/*
Copyright (c) 2013, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE. Written by Nathan Wisman.
*/

public with sharing class BPTCallout {
    private static final String BPT_URL = System.Label.BPT_API_URL; // As of January 2013: https://www.brownpapertickets.com/api2/
    private static Opportunity[] opptyList = new List<Opportunity>();
    public static BPT_Configuration__c bpt_config { get; set; }
    public static Integer opptyNumber { get; private set; }
    public static Boolean integFailure { get; private set; }
    public static Boolean noOpptys { get; private set; }
    public Map<String,cString> eventIdStrMap { get; set; }
    public Boolean opptysCreated { get; private set; }
    public Boolean eventsFound { get; private set; }
    public Boolean noEvents { get; private set; }
    public Boolean campSaved { get; private set; }
    public Boolean campSaveFail { get; private set; }
    public Boolean noCampPerms { get; private set; }
    public Boolean noOpptyPerms { get; private set; }
    public Id newCampId { get; set; }
    public String campString { get; set; }
    public String eventIdStr { get; set; }
    public Static String login { get; set; }
    public Static String devid { get; set; }
    public String finalUrl;
    public transient HttpResponse response { get; set; }

    static {
        bpt_config = BPT_Configuration__c.getInstance('Main Settings Record');
        if (bpt_config != null && bpt_config.Dev_ID__c != null && bpt_config.Login__c != null) {
            login = bpt_config.Login__c;
            devid = bpt_config.Dev_ID__c;
        }
    }

    public pageReference saveConfig() {
        if (bpt_config != null) {
        	bpt_config.Login__c = login;
        	bpt_config.Dev_ID__c = devid;
            update bpt_config;
        }
        else {
        	if (String.isNotBlank(devid) && String.isNotBlank(login)) {
	            BPT_Configuration__c bp = new BPT_Configuration__c(Name='Main Settings Record', Dev_ID__c=devid, Login__c=login);
	            insert bp;
        	}
        }
        return null;
    }

    /* Prepares and makes a REST call to the Brown Paper Tickets API to retrieve a list of Event Sales */
    public pageReference setEventCallout() {
        if (String.isNotBlank(login) && String.isNotBlank(devid)) {
            // Example: https://www.brownpapertickets.com/api2/eventsales?id=mk324mf3&account=emailaddy@emaildomain.com
            finalUrl = BPT_URL + 'eventsales' + '?' + 'id=' + devid + '&account=' + login;
            callBPT(finalUrl);

            if (response != null && response.getStatusCode() == 200 && response.getBody().length() > 129) {
                getCampaignContent(response);
            }
            else {
                integFailure = true;
            }
        }
        return null;
    }

    /* Prepares and makes a REST call to the Brown Paper Tickets API to retrieve a list of ticket Orders */
    public pageReference setOpptyCallout() {
        integFailure = false;
        campSaved = false;

        if (Schema.sObjectType.Opportunity.isCreateable()) {
            // pullfeed, devId, acct are all mandatory parameters
            if (String.isNotBlank(eventIdStr) && String.isNotBlank(login) && String.isNotBlank(devid)) {
                // Example: https://www.brownpapertickets.com/api2/orderlist?id=mk324mf3&account=emailaddy@emaildomain.com&event_id=425233
                finalUrl = BPT_URL + 'orderlist' + '?' + 'id=' + devid + '&account=' + login + '&event_id=' + eventIdStr;
                callBPT(finalUrl);

                if (response != null && response.getStatusCode() == 200 && response.getBody().length() > 129) {
                    getOpptyContent(response, eventIdStr);
                }
                else if (response != null && response.getStatusCode() == 200 && response.getBody().length() < 120) {
                    noOpptys = true;
                    opptysCreated = false;
                }
                else {
                    integFailure = true;
                    opptysCreated = false;
                }
            }
        }
        else {
            noOpptyPerms = true;
        }
        return null;
    }

    /* Performs REST call to Brown Paper Tickets API */
    public void callBPT(String url) {
        //System.debug('$$$ URL: ' + url);
        if (String.isNotBlank(url)) {
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
            //System.debug('$$$ req: ' + req);

            // Send the request, and return a response
            Http h = new Http();

            try {
                response = h.send(req);
                // header keys: (null, MIME-Version, Date, Content-Length, Set-Cookie, Connection, Content-Type, Server)
                //System.debug('$$$ RESPONSE.GETBODY: ' + response.getBody());
            } catch (CalloutException ce) {
                  //System.debug('ClassName: BPTCallout, CalloutException: ' + ce);
                  integFailure = true;
            }
        }
    }

    /* Process REST response from API via our XML Parsing class, BPTXmlParser, for Event Sales */
    public void getCampaignContent(HttpResponse res) {
        if (res != null && res.getStatusCode() == 200) {
            BPTXmlParser bparse = new BPTXmlParser(res.getXmlStreamReader(), null);
            eventIdStrMap = new Map<String,cString>();

            if (bparse != null) {
                // Now get our list of Strings structured like: c.Name + '-' + c.Event_Number__c + '-' + c.Event_Link__c
                String[] sList = bparse.getEventStringList();
                sList.sort();

                // Use the list to create wrapper objects, to display in visualforce
                if (sList != null && !sList.isEmpty()) {
                    for (String s: sList) {
                        cString c = new cString(s);

                        if (c != null)
                            eventIdStrMap.put(c.eventId, c);

                    }

                    deDupeCampaigns();
                    eventsFound = true;
                }
            }
            else {
                integFailure = true;
            }
        }
    }

    /* Process REST response from API via our XML Parsing class, BPTXmlParser, for ticket Orders */
    public String getOpptyContent(HttpResponse res, String eventIdString) {
        if (res != null && res.getStatusCode() == 200 && String.isNotBlank(eventIdString)) {
            BPTXmlParser bparse = new BPTXmlParser(res.getXmlStreamReader(), eventIdString);

            if (bparse != null) {
                opptyList = bparse.getOpptyMap().values();

                if (!opptyList.isEmpty()) {
                    try {
                        // DML Operation will save all records possible.
                        Database.SaveResult[] saveResultList = Database.Insert(opptyList, false);
                        opptyNumber = opptyList.size();
                        noOpptys = false;
                        opptysCreated = true;
                    }
                    catch (DMLException de) {
                        //System.debug('ClassName: BPTCallout, DMLException: ' + de);
                        integFailure = true;
                    }
                }
                else {
                    noOpptys = true;
                    opptysCreated = false;
                }
            }
            else {
                integFailure = true;
                opptysCreated = false;
            }
        }

        return res.getBody();
    }

    /* Saves BPT Events as Campaigns, via visualforce commandlink */
    public pageReference saveAsCampaign() {
        Campaign newCamp = new Campaign();
        String[] splitArr = new List<String>();
        opptysCreated = false;

        if (Schema.sObjectType.Campaign.isCreateable()) {
            if (String.isNotBlank(campString)) {
                splitArr = campString.split('\\^');

                if (splitArr != null && splitArr.size() == 3) {
                    newCamp.Name = splitArr[0].trim();
                    newCamp.Event_Link__c = splitArr[1].trim();
                    newCamp.Event_Number__c = splitArr[2].trim();
                    newCamp.Type = 'Brown Paper Tickets';
                    newCamp.Description = 'Created by the Brown Paper Tickets Integration app, found on the AppExchange.';
                    newCamp.Status = 'In Progress';

                    try {
                        Database.SaveResult dbsr = Database.insert(newCamp);
                        newCampId = dbsr.getId();
                        campSaved = true;
                        campSaveFail = false;

                        // Now mark our event wrapper class objects as existing
                        if (eventIdStrMap != null && eventIdStrMap.containsKey(newCamp.Event_Number__c)) {
                            eventIdStrMap.get(newCamp.Event_Number__c).exists = true;
                            eventIdStrMap.get(newCamp.Event_Number__c).campId = dbsr.getId();
                        }
                } catch (DMLException de) {
                          campSaved = false;
                          campSaveFail = true;
                          //System.debug('ClassName: BPTCallout, DMLException on Campaign insert: ' + de);
                    }
                }
           }
        }
        else {
            noCampPerms = true;
        }

        return null;
    }

    /* Queries for and marks any Campaigns that are duplicates, based on ticket number. */
    private void deDupeCampaigns() {
        Set<String> dupeCampSet = new Set<String>();

        if (!eventIdStrMap.isEmpty()) {
            for (Campaign c: [select Id, Name, Event_Number__c from Campaign where Event_Number__c in :eventIdStrMap.keySet()]) {
                if (eventIdStrMap.containsKey(c.Event_Number__c)) {
                    eventIdStrMap.get(c.Event_Number__c).exists = true;
                    eventIdStrMap.get(c.Event_Number__c).campId = c.Id;
                }
            }
        }
    }

    /* GETTERS */
    public static Opportunity[] getOpptyList() { return opptyList; }


    /* Wrapper Class for Brown Paper Tickets events displayed in visualforce */
    public with sharing class cString {
        public Boolean exists   { get; set; }
        public String allStrs   { get; set; }
        public String nameStr   { get; set; }
        public String eventId   { get; set; }
        public String eventLink { get; set; }
        public String campId    { get; set; }

        public cString(String inputStr) {
            String[] strArray = new List<String>();

            if (inputStr != null && inputStr.split('\\^') != null && inputStr.split('\\^').size() == 3) {
                allStrs = inputStr;
                strArray = inputStr.split('\\^');
                nameStr = strArray[0].trim();
                eventLink = strArray[1].trim();
                eventId = strArray[2].trim();
                exists = false;
            }
        }
    }
}