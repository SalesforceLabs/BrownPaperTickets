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

public with sharing class BPTXmlParser {
    private static final Set<String> ORDER_ATTRIBUTE_SET = new Set<String>(), EVENT_ATTRIBUTE_SET = new Set<String>();
    private Map<String, Opportunity> opptyMap = new Map<String, Opportunity>();
    private Campaign existingCamp = new Campaign();
    private Set<String> ticketNumSet = new Set<String>(), eventIdSet = new Set<String>();
    private Opportunity o = newOpportunity();
    private String eventString='';
    private Campaign[] existList = new List<Campaign>();
    public String[] eventStringList = new List<String>();

    static {
        // This set tracks which XML response attributes we're writing onto our sObject
        ORDER_ATTRIBUTE_SET.addAll(Label.BPT_Order_Attributes.split(';'));
        EVENT_ATTRIBUTE_SET.addAll(Label.BPT_Event_Attributes.split(';'));
    }

    public BPTXmlParser(XmlStreamReader rdrr, String eventIdStrng) {
        if (rdrr != null && ORDER_ATTRIBUTE_SET != null && EVENT_ATTRIBUTE_SET != null) {
            // Query existing Campaigns in order to later associate our new Opportunities to them
            if (eventIdStrng != null && eventIdStrng.length() >= 4)
                queryCampaigns(eventIdStrng);

            parseXml(rdrr);
        }
    }

    public void queryCampaigns(String eventId) {
        if (String.isNotBlank(eventId)) {
            try {
                existList = [select Id, Name, Event_Number__c from Campaign where Event_Number__c = :eventId Limit 1];
            } catch(ListException le) {
                  System.debug('ClassName: BPTXMLParser, ListException: ' + le);
            }

            if (!existList.isEmpty()) {
                existingCamp = existList[0];
            }
        }
    }

   /*
    * Loop through XML elements, grabbing the ones we care about and
    * stamping their values into new Opportunities.
    */
    public void parseXml(XmlStreamReader reader) {
        Boolean orders = false, events = false;
        String localName;

        if (reader != null) {
            while (reader.hasNext() && opptyMap.values().size() < 40) {
                if (reader.getEventType() == XmlTag.END_DOCUMENT) {
                    break;
                }
                else if (reader.getEventType() == XmlTag.START_ELEMENT) {
                    if (EVENT_ATTRIBUTE_SET.contains(reader.getLocalName())) {
                        events = true;
                        localName = reader.getLocalName();
                    }

                    if (ORDER_ATTRIBUTE_SET.contains(reader.getLocalName())) {
                        orders = true;
                        localName = reader.getLocalName();
                    }
                }

                if (orders == true) {
                    if (reader.getEventType() == XmlTag.CHARACTERS && reader.getText() != null && String.isNotBlank(localName)) {
                        setOppty(localName, reader.getText());
                        orders = false;
                    }
                }
                else if (events == true) {
                    if (reader.getEventType() == XmlTag.CHARACTERS && reader.getText() != null && String.isNotBlank(localName)) {
                        setCampaign(localName, reader.getText());
                        events = false;
                    }
                }
                reader.next();
            }

            // Prevent any duplicates of Opportunities that are already in Salesforce
            if (!opptyMap.isEmpty()) {
                deDupeOpptys();
            }
        }
    }

   /*
    * Based on which attribute we're working with, write its value into
    * the appropriate Opportunity field
    */
    private void setOppty(String locName, String textVal) {
    	if (String.isNotBlank(textVal)) {
	        if (locName == 'fname') {
	            o.Name = existingCamp.Name + ' - ' + textVal;
	        }
	        else if (locName == 'lname') {
	            o.Name += ' ' + textVal;
	        }
	        else if (locName == 'address') {
	            o.Street_Address__c = textVal;
	        }
	        else if (locName == 'city') {
	            o.City__c = textVal;
	        }
	        else if (locName == 'state') {
	            o.State__c = textVal;
	        }
	        else if (locName == 'zip') {
	            o.Zip_Code__c = textVal;
	        }
	        else if (locName == 'email') {
	            o.BPT_Email__c = textVal;
	        }
	        else if (locName == 'price_id') {
	
	        }
	        else if (locName == 'quantity') {
	            o.TotalOpportunityQuantity = decimal.valueOf(textVal);
	            o.Number_of_Tickets__c = decimal.valueOf(textVal);
	        }
	        else if (locName == 'phone') {
	            o.Phone_Number__c = textVal;
	        }
	        else if (locName == 'ticket_number') {
	            o.Ticket_Number__c = textVal;
	
	            if (existingCamp.Id != null) {
	                o.CampaignId = existingCamp.Id; // Stamp corresponding Campaign ID
	            }
	            
	            o.BPT_Event_Id__c = existingCamp.Event_Number__c; // Stamp corresponding Brown Paper Tickets Event ID
	
	            opptyMap.put(o.Ticket_Number__c, o.clone(true, false, false));
	            o = newOpportunity();
	            ticketNumSet.add(textVal);
	        }
    	}
    }

   /*
    * Based on which attribute we're working with, write its value into
    * the appropriate Campaign field
    */
    private void setCampaign(String locName, String textVal) {
    	if (String.isNotBlank(textVal)) {
	        if (locName == 'title') {
	            eventString = textVal;
	        }
	        else if (locName == 'link') {
	            eventString += '^' + textVal;
	        }
	        else if (locName == 'e_number') {
	            eventIdSet.add(textVal);
	            eventString += '^' + textVal;

	            eventStringList.add(String.valueOf(eventString));
	            eventString = '';
	        }
    	}
    }

   /*
    * Create a new Opportunity with default initial attributes. In a separate method so
    * we only have to modify these attributes in one place.
    */
    private Opportunity newOpportunity() {
        return new Opportunity(StageName='Closed Won', CloseDate=System.today());
    }

    /* Queries for and removes any Opportunities that are duplicates, based on ticket number. */
    private void deDupeOpptys() {
        for (Opportunity o: [select Id, Ticket_Number__c from Opportunity where Ticket_Number__c in :ticketNumSet]) {
            if (opptyMap.containsKey(o.Ticket_Number__c)) {
                opptyMap.remove(o.Ticket_Number__c);
            }
        }
    }

    /* GETTERS */
    public String[] getEventStringList() { return eventStringList; }
    public Set<String> getEventIdSet() { return eventIdSet; }
    public Map<String,Opportunity> getOpptyMap() { return opptyMap; }
}