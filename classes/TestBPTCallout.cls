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

@isTest
private class TestBPTCallout {
    private static HttpResponse resVar;

    private static final String NO_ORDER_STR = '<?xml version=\"1.0\"?><document></document>';
    
    private static final String SHORT_ORDER_STR = '<?xml version=\"1.0\"?>' +
                                                    '<document>' +
                                                    '<result>success</result>' +
                                                    '<resultcode>000000</resultcode>' +
                                                    '<note></note>' +
                                                    '</document>';

    private static final String ORDER_XML_STR = '<?xml version=\"1.0\"?>' +
                                                    '<document>' +
                                                     '<result>success</result>' +
                                                     '<resultcode>000000</resultcode>' +
                                                     '<note></note>' +
                                                     '<item>' +
                                                        '<order_time>2012-11-29 10:22:34</order_time>' +
                                                        '<date_id>742008</date_id>' +
                                                        '<price_id>2029583</price_id>' +
                                                        '<quantity>5</quantity>' +
                                                        '<fname>Bob</fname>' +
                                                        '<lname>Tungsten</lname>' +
                                                        '<address>23232 Fleet Street</address>' +
                                                        '<city>Santa Clara</city>' +
                                                        '<state>CA</state>' +
                                                        '<zip>94105</zip>' +
                                                        '<country>United States</country>' +
                                                        '<email>btung@yahoo.com</email>' +
                                                        '<phone>4155555555</phone>' +
                                                        '<cc>N/A</cc>' +
                                                        '<shipping_method>Physical</shipping_method>' +
                                                        '<order_notes></order_notes>' +
                                                        '<ticket_number>A22647604</ticket_number>' +
                                                        '<section>33</section>' +
                                                        '<row>C</row>' +
                                                        '<seat>23</seat>' +
                                                     '</item>' +
                                                     '<item>' +
                                                        '<order_time>2012-11-29 10:25:34</order_time>' +
                                                        '<date_id>742008</date_id>' +
                                                        '<price_id>2029583</price_id>' +
                                                        '<quantity>5</quantity>' +
                                                        '<fname>Bob</fname>' +
                                                        '<lname>Tungsten</lname>' +
                                                        '<address>23232 Fleet Street</address>' +
                                                        '<city>Santa Clara</city>' +
                                                        '<state>CA</state>' +
                                                        '<zip>94105</zip>' +
                                                        '<country>United States</country>' +
                                                        '<email>btung@yahoo.com</email>' +
                                                        '<phone>4155555555</phone>' +
                                                        '<cc>N/A</cc>' +
                                                        '<shipping_method>Physical</shipping_method>' +
                                                        '<order_notes></order_notes>' +
                                                        '<ticket_number>A22647605</ticket_number>' +
                                                        '<section>33</section>' +
                                                        '<row>C</row>' +
                                                        '<seat>23</seat>' +
                                                     '</item>' +
                                                   '</document>';

    private static final String EVENT_XML_STR = '<?xml version=\"1.0\"?>' +
                                                    '<document>' +
                                                    '<result>success</result>' +
                                                    '<resultcode>000000</resultcode>' +
                                                    '<note></note>' +
                                                    '<event>' +
                                                        '<title>Test Developer Event 1</title>' +
                                                        '<link>http://www.brownpapertickets.com/event/888888</link>' +
                                                        '<e_number>888888</e_number>' +
                                                        '<event_status>Active</event_status>' +
                                                        '<tickets_sold>900</tickets_sold>' +
                                                        '<collected_value>0.00</collected_value>' +
                                                        '<paid_value>0.00</paid_value>' +
                                                    '</event>' +
                                                    '<event>' +
                                                        '<title>Test Developer Event 2</title>' +
                                                        '<link>http://www.brownpapertickets.com/event/42344</link>' +
                                                        '<e_number>42344</e_number>' +
                                                        '<event_status>Active</event_status>' +
                                                        '<tickets_sold>3</tickets_sold>' +
                                                        '<collected_value>0.00</collected_value>' +
                                                        '<paid_value>0.00</paid_value>' +
                                                    '</event>' +
                                                '</document>';

    /* Test processing BPT Orders into Opportunities...*/
    static testmethod void testFailOpptys() {    
        // Set test URL and mock callout class
        String testUrl = 'https://www.brownpapertickets.com/api2/orderlist?id=12tstdvid3&account=testacct@emailaddy.com&event_id=888888';
        Test.setMock(HttpCalloutMock.class, new BPTMockHttpRespGenerator());

        // Call method to test. This causes a fake response to be sent from the class that implements HttpCalloutMock.
        BPTCallout resTest = new BPTCallout();
        BPTCallout.login = 'testacct@emailaddy.com';
        BPTCallout.devid = '12tstdvid3';

        resTest.eventIdStr = '888888';
        resTest.setOpptyCallout();
        System.assertNotEquals(null, resTest.finalUrl);
    }

  /*  static testMethod void testCustomSettingConfig() {
        delete [select Id from BPT_Configuration__c];

        BPTCallout resTest = new BPTCallout();
        System.assertEquals(BPTCallout.devid, null);
        System.assertEquals(BPTCallout.login, null);

        BPT_Configuration__c b = new BPT_Configuration__c(Name='Main Settings Record', Dev_ID__c = 'testdevid', Login__c = 'testemail');
        insert b;
        System.assertNotEquals(null, b.Id);
        BPTCallout resTest2 = new BPTCallout();
       // System.assertNotEquals(null, BPTCallout.bpt_config);
       // System.assertEquals(BPTCallout.devid, 'testdevid');
       // System.assertEquals(BPTCallout.login, 'testemail');

        System.assertEquals(null, resTest2.saveConfig());
        System.assertEquals(null, resTest.setEventCallout());
    }
    
    static testMethod void testCustomSettingConfig2() {
        BPT_Configuration__c b = new BPT_Configuration__c(Name='Main Settings Record', Dev_ID__c = 'testdevid', Login__c = 'testemail');
        insert b;
        System.assertNotEquals(null, b.Id);
        
        Test.startTest();
        BPTCallout resTest2 = new BPTCallout();
        System.assertNotEquals(null, BPTCallout.bpt_config);
        System.assertEquals(BPTCallout.devid, 'testdevid');
        System.assertEquals(BPTCallout.login, 'testemail');

        System.assertEquals(null, resTest2.saveConfig());
        System.assertEquals(null, resTest2.setEventCallout());
        Test.stopTest();
    }

    /* Test processing BPT Orders into Opportunities...*/
    static testmethod void testCalloutOpptys() {
        // Set test URL and mock callout class
        String testUrl = 'https://www.brownpapertickets.com/api2/orderlist?id=12tstdvid3&account=testacct@emailaddy.com&event_id=888888';
        Test.setMock(HttpCalloutMock.class, new BPTMockHttpRespGenerator());

        // Call method to test. This causes a fake response to be sent from the class that implements HttpCalloutMock.
        BPTCallout resTest = new BPTCallout();
        resTest.callBPT(testUrl);
        HttpResponse res = resTest.response;
        System.assertNotEquals(null, res);

        // Verify response received contains fake values
        String actualValue = res.getBody();
        String expectedValue = ORDER_XML_STR;
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());

        // Insert a Campaign to link our new Opptys to
        Campaign c = new Campaign(Name='BPT Event', Event_Number__c='888888');
        insert c;
        System.assertNotEquals(null, c.Id);

        // Now generate our Opportunities by processing the XML content gathered above
        resTest.getOpptyContent(res, c.Event_Number__c);

        Opportunity[] oList = BPTCallout.getOpptyList();
        System.assertEquals(oList.size(), 2);
        System.assert(!BPTCallout.noOpptys);
        System.assert(resTest.opptysCreated);
        System.assertEquals(null, BPTCallout.integFailure);
        System.assertEquals(BPTCallout.opptyNumber, 2);

        Set<Id> idSet = new Set<Id>();
        idSet.add(oList[0].Id);
        idSet.add(oList[1].Id);

        // Check that Oppty values are correct
        for (Opportunity o: [select Id,
                                    Name,
                                    Street_Address__c,
                                    City__c,
                                    Zip_Code__c,
                                    BPT_Email__c,
                                    Phone_Number__c,
                                    TotalOpportunityQuantity,
                                    BPT_Event_Id__c,
                                    Row_and_Seat__c
                              from Opportunity
                              where Id in :idSet]) {
            System.assertNotEquals(o.Id, null);
            System.assertEquals(o.Name, 'BPT Event - Bob Tungsten');
            System.assertEquals(o.Street_Address__c, '23232 Fleet Street');
            System.assertEquals(o.City__c, 'Santa Clara');
            System.assertEquals(o.Zip_Code__c, '94105');
            System.assertEquals(o.BPT_Email__c, 'btung@yahoo.com');
            System.assertEquals(o.Phone_Number__c, '4155555555');
            System.assertEquals(o.TotalOpportunityQuantity, 5);
            System.assertEquals(o.BPT_Event_Id__c, '888888');
            System.assertEquals(o.Row_and_Seat__c, 'Section 33, Row C, Seat 23');
        }
    }

    /* Test processing BPT Events into Campaigns */
    static testmethod void testCalloutEvents() {
        // Generate BPT Events as Campaigns first
        BPTCallout resTest;
        String testUrl = 'https://www.brownpapertickets.com/api2/eventsales?id=12tstdvid3&account=testacct@emailaddy.com';

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new BPTMockEventHttpRespGen());

        resTest = new BPTCallout();
        resTest.callBPT(testUrl);
        HttpResponse res = resTest.response;
        System.assertNotEquals(null, res);
        resVar = res;

        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/xml');
        String actualValue = res.getBody();
        String expectedValue = EVENT_XML_STR;
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());

        resTest.getCampaignContent(res);

        System.assert(resTest.eventsFound);
        System.assertEquals(null, BPTCallout.integFailure);

        // Now commit our Campaigns to database (note that we can only save one at a time, per visualforce interface)
        String campString1 = 'Test Developer Event 1^http://www.brownpapertickets.com/event/888888^888888';
        String campString2 = 'Test Developer Event 2^http://www.brownpapertickets.com/event/42344^42344';
        
        System.assertEquals(null, resTest.campSaved);
        System.assertEquals(null, resTest.campSaveFail);

        resTest.campString = campString1;
        resTest.saveAsCampaign();

        resTest.campString = campString2;
        resTest.saveAsCampaign();

        Campaign campaign1 = [select Id, Name, Event_Link__c, Event_Number__c, Type, Description, Status from Campaign where Event_Number__c = '888888'];
        System.assertNotEquals(null, campaign1.Id);
        System.assert(resTest.campSaved);
        System.assert(!resTest.campSaveFail);
        System.assertEquals(campaign1.Event_Link__c, 'http://www.brownpapertickets.com/event/888888');
        System.assertEquals(campaign1.Status, 'In Progress');
        System.assertEquals(campaign1.Type, 'Brown Paper Tickets');
        System.assertEquals(campaign1.Description, 'Created by the Brown Paper Tickets Integration app, found on the AppExchange.');

        Campaign campaign2 = [select Id, Name, Event_Link__c, Event_Number__c, Type, Description, Status from Campaign where Event_Number__c = '42344'];
        System.assertNotEquals(null, campaign2.Id);
        System.assert(resTest.campSaved);
        System.assert(!resTest.campSaveFail);
        System.assertEquals(campaign2.Event_Link__c, 'http://www.brownpapertickets.com/event/42344');
        System.assertEquals(campaign2.Status, 'In Progress');
        System.assertEquals(campaign2.Type, 'Brown Paper Tickets');
        System.assertEquals(campaign2.Description, 'Created by the Brown Paper Tickets Integration app, found on the AppExchange.');

        Set<String> eventNumStrings = new Set<String>();
        eventNumStrings.add(campaign1.Event_Number__c);
        eventNumStrings.add(campaign2.Event_Number__c);

        // Now manually re-create Event to see if it is marked "exists" by DeDupe method
        resTest.getCampaignContent(res);
        for (BPTCallout.cString c: resTest.eventIdStrMap.values()) {
            System.assert(c.exists);
            System.assert(eventNumStrings.contains(c.eventId));
        }
    }
    
    /* Test that having a user with wrong permissions will prevent Opportunity creation */
    static testmethod void opptyPermissionsTest() {
        // Set test URL and mock callout class
        String testUrl = 'https://www.brownpapertickets.com/api2/orderlist?id=12tstdvid3&account=testacct@emailaddy.com&event_id=888888';
        Test.setMock(HttpCalloutMock.class, new BPTMockHttpRespGenerator());

        // Call method to test. This causes a fake response to be sent from the class that implements HttpCalloutMock.
        BPTCallout resTest = new BPTCallout();
        resTest.callBPT(testUrl);
        HttpResponse res = resTest.response;
        System.assertNotEquals(null, res);

        // Verify response received contains fake values
        String actualValue = res.getBody();
        String expectedValue = ORDER_XML_STR;
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());

        // Insert a Campaign to link our new Opptys to
        Campaign c = new Campaign(Name='888888', Event_Number__c='888888');
        insert c;
        System.assertNotEquals(null, c.Id);

        // Now check that creating our Opportunities fails due to a lack of permissions
        Id readOnly = [select Id, Name from Profile where Name = 'Read Only' Limit 1].Id;
        User failUser = new User(LastName='testCoverage', Alias='testc', Email='test@test.com', Username='test@testcdknf.com',
                                 CommunityNickname='isdhfb', ProfileId=readOnly, TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US',
                                 EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert failUser;
        System.assertNotEquals(null, failUser.Id);

        System.runAs(failUser) {
            resTest.setOpptyCallout();
        }

        Opportunity[] oList = BPTCallout.getOpptyList();
        System.assertEquals(oList.size(), 0);
        System.assert(resTest.noOpptyPerms);
    }
    
    /* Test that having a user with wrong permissions will prevent Campaign creation */
    static testmethod void campaignPermissionsTest() {
        // Generate BPT Events as Campaigns first
        BPTCallout resTest;
        String testUrl = 'https://www.brownpapertickets.com/api2/eventsales?id=12tstdvid3&account=testacct@emailaddy.com';

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new BPTMockEventHttpRespGen());

        resTest = new BPTCallout();
        resTest.callBPT(testUrl);
        HttpResponse res = resTest.response;
        System.assertNotEquals(null, res);
        resVar = res;

        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/xml');
        String actualValue = res.getBody();
        String expectedValue = EVENT_XML_STR;
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());

        resTest.getCampaignContent(res);

        System.assert(resTest.eventsFound);
        System.assertEquals(null, BPTCallout.integFailure);

        // Now commit our Campaigns to database (note that we can only save one at a time, per visualforce interface)
        String campString1 = 'Test Developer Event 1-http://www.brownpapertickets.com/event/888888-888888';
        String campString2 = 'Test Developer Event 2-http://www.brownpapertickets.com/event/42344-42344';

        System.assertEquals(null, resTest.campSaved);
        System.assertEquals(null, resTest.campSaveFail);

        Id readOnly = [select Id, Name from Profile where Name = 'Read Only' Limit 1].Id;
        User failUser = new User(LastName='testCoverage', Alias='testc', Email='test@test.com', Username='test@testcdknf.com',
                                 CommunityNickname='isdhfb', ProfileId=readOnly, TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US',
                                 EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert failUser;
        System.assertNotEquals(null, failUser.Id);

        resTest.campString = campString1;

        System.runAs(failUser) {
            resTest.saveAsCampaign();
        }

        System.assert(resTest.noCampPerms);
        System.assertEquals(0, [select count() from Campaign where Event_Number__c = '888888']);
    }

    /* Test some additional BPTCallout controller functionality, including settings updates and our inner cString class */
    private static testMethod void testControllerFunctions1() {
        BPTCallout testCall = new BPTCallout();
        testCall.setEventCallout();

        // Instantiate a page reference for our visualforce
        PageReference pageRef = Page.BPTsettingsPage;
        Test.setCurrentPage(pageRef);

        Test.setMock(HttpCalloutMock.class, new BPTMockEventHttpRespGen());

        // Instantiate our controller
        BPTCallout bptCntrl = new BPTCallout();

        System.assertEquals(null, bptCntrl.opptysCreated);
        System.assertEquals(null, bptCntrl.eventIdStrMap);

        String testStr = 'ghbneventNamer3^http://www.eventlink.org/12345^12345';

        BPTCallout.cString testC = new BPTCallout.cString(testStr);
        System.assertEquals(testC.allStrs, testStr);
        System.assertEquals(testC.nameStr, 'ghbneventNamer3');
        System.assertEquals(testC.eventId, '12345');
        System.assertEquals(testC.eventLink, 'http://www.eventlink.org/12345');
    }

    /* Test that obtaining Events and Orders fails when incorrect request info is given */
    static testMethod private void failTest1() {
        // Instantiate a page reference for our vf
        PageReference pageRef = Page.BPTSettingsPage;
        Test.setCurrentPage(pageRef);

        // Instantiate our controller
        BPTCallout bptCntrl = new BPTCallout();

        System.assertEquals(null, bptCntrl.opptysCreated);
        System.assertEquals(null, bptCntrl.setOpptyCallout());

        // Create a String of invalid length when split via hyphens
        String testStr = 'wflksd^ghbneventNamer3^12345-http://www.eventlink.org/^kmfds';

        BPTCallout.cString testC = new BPTCallout.cString(testStr);
        System.assertEquals(testC.allStrs, null);
        System.assertEquals(testC.nameStr, null);
        System.assertEquals(testC.eventId, null);
        System.assertEquals(testC.eventLink, null);
        System.assertEquals(testC.campId, null);
        System.assertEquals(testC.exists, null);

        // Now let's test Campaign insert failure functionality
        bptCntrl.campString = testStr;
        System.assertEquals(null, bptCntrl.saveAsCampaign());
        System.assertEquals(0, [select count() from Campaign where Name = 'ghbneventNamer3']);

        System.assertEquals(bptCntrl.newCampId, null);
    } /* */
}