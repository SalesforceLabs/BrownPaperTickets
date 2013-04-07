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
OF THE POSSIBILITY OF SUCH DAMAGE. Written by nwisman.
*/

@isTest
private class TestBPTXmlParser {
    private static Set<Id> idSet = new Set<Id>();

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
                                                        '<section>1</section>' +
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
                                                        '<section>1</section>' +
                                                        '<row>C</row>' +
                                                        '<seat>24</seat>' +
                                                     '</item>' +
                                                     '<item>' +
                                                        '<order_time>2012-12-23 10:25:34</order_time>' +
                                                        '<date_id>742008</date_id>' +
                                                        '<price_id>2029583</price_id>' +
                                                        '<quantity>2</quantity>' +
                                                        '<fname>Zip</fname>' +
                                                        '<lname>Olsen</lname>' +
                                                        '<address>3243 Maple Street</address>' +
                                                        '<city>Sunnyvale</city>' +
                                                        '<state>CA</state>' +
                                                        '<zip>94105</zip>' +
                                                        '<country>United States</country>' +
                                                        '<email>zolsen@gmail.com</email>' +
                                                        '<phone>3249014545</phone>' +
                                                        '<cc>N/A</cc>' +
                                                        '<shipping_method>Physical</shipping_method>' +
                                                        '<order_notes></order_notes>' +
                                                        '<ticket_number>A22637405</ticket_number>' +
                                                        '<section>4</section>' +
                                                        '<row>A</row>' +
                                                        '<seat>18</seat>' +
                                                     '</item>' +
                                                   '</document>';
        
        private static final String ORDER_XML_STR2 = '<?xml version=\"1.0\"?>' +
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
                                                        '<section>1</section>' +
                                                        '<row></row>' +
                                                        '<seat></seat>' +
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
                                                        '<section>1</section>' +
                                                        '<row></row>' +
                                                        '<seat></seat>' +
                                                     '</item>' +
                                                   '</document>';
                                                   
    private static final String ORDER_XML_STR3 = '<?xml version=\"1.0\"?>' +
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
                                                        '<section>2</section>' +
                                                        '<row>C</row>' +
                                                        '<seat>33</seat>' +
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
                                                        '<section></section>' +
                                                        '<row></row>' +
                                                        '<seat></seat>' +
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
                                                        '<ticket_number>A22647606</ticket_number>' +
                                                        '<section>2</section>' +
                                                        '<row>E</row>' +
                                                        '<seat>44</seat>' +
                                                     '</item>' +
                                                   '</document>';

    private static final String EVENT_XML_STR = '<?xml version=\"1.0\"?>' +
                                                    '<document>' +
                                                    '<result>success</result>' +
                                                    '<resultcode>000000</resultcode>' +
                                                    '<note></note>' +
                                                    '<event>' +
                                                        '<title>Test Developer Event 1</title>' +
                                                        '<link>http://www.brownpapertickets.com/event/2343244</link>' +
                                                        '<e_number>2343244</e_number>' +
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

    /* Test basic Campaign and Opportunity creation and insertion functionality */
    @isTest
    static private void xmlOrderParserTest1() {
        // Let's first process our actual Events into Campaigns
        XmlStreamReader reader = new XmlStreamReader(EVENT_XML_STR);
        BPTXmlParser bParseTest = new BPTXmlParser(reader, null);

        System.assertEquals(2, bParseTest.getEventStringList().size());
        System.assertEquals('Test Developer Event 1^http://www.brownpapertickets.com/event/2343244^2343244', bParseTest.getEventStringList()[0]);
        System.assertEquals('Test Developer Event 2^http://www.brownpapertickets.com/event/42344^42344', bParseTest.getEventStringList()[1]);

        reader = new XmlStreamReader(EVENT_XML_STR);
        BPTXmlParser bParseTest2 = new BPTXmlParser(reader, null);

        // Now insert a Campaign for our Opportunities to be linked to
        Campaign existingCampaign = new Campaign(Name='Test Developer Event 1', Event_Number__c='2343244', Event_Link__c='http://www.brownpapertickets.com/event/2343244');
        insert existingCampaign;
        System.assertNotEquals(null, existingCampaign.Id);

        // Now let's process the orders from these Events into Opportunities
        reader = new XmlStreamReader(ORDER_XML_STR);
        bParseTest = new BPTXmlParser(reader, '2343244');
        Opportunity[] oList = bParseTest.getOpptyMap().values();

        System.assertEquals(oList.size(), 2);
        insert oList;
        idSet.add(oList[0].Id);
        idSet.add(oList[1].Id);

        for (Opportunity o: [select Id,
                                    Name,
                                    Street_Address__c,
                                    City__c,
                                    Zip_Code__c,
                                    BPT_Email__c,
                                    Phone_Number__c,
                                    TotalOpportunityQuantity,
                                    BPT_Event_Id__c,
                                    Seat_Location__c
                              from Opportunity
                              where Id in :idSet]) {
            if (o.Name == 'Test Developer Event 1 - Bob Tungsten') {
                System.assertNotEquals(o.Id, null);
                System.assertEquals(o.Name, 'Test Developer Event 1 - Bob Tungsten');
                System.assertEquals(o.Street_Address__c, '23232 Fleet Street');
                System.assertEquals(o.City__c, 'Santa Clara');
                System.assertEquals(o.Zip_Code__c, '94105');
                System.assertEquals(o.BPT_Email__c, 'btung@yahoo.com');
                System.assertEquals(o.Phone_Number__c, '4155555555');
                System.assertEquals(o.TotalOpportunityQuantity, 10.00);
                System.assertEquals(o.Seat_Location__c, 'Section 1,Row C,Seat 23;Section 1,Row C,Seat 24');
                System.assertEquals(o.BPT_Event_Id__c, '2343244');
            }
            else if (o.Name == 'Test Developer Event 1 - Zip Olsen') {
                System.assertEquals(o.Name, 'Test Developer Event 1 - Zip Olsen');
                System.assertEquals(o.Street_Address__c, '3243 Maple Street');
                System.assertEquals(o.City__c, 'Sunnyvale');
                System.assertEquals(o.Zip_Code__c, '94105');
                System.assertEquals(o.BPT_Email__c, 'zolsen@gmail.com');
                System.assertEquals(o.Phone_Number__c, '3249014545');
                System.assertEquals(o.TotalOpportunityQuantity, 2.00);
                System.assertEquals(o.Seat_Location__c, 'Section 4,Row A,Seat 18');
                System.assertEquals(o.BPT_Event_Id__c, '2343244');
            }
            else {
                // Just force an exception if there is a misnamed Opportunity
                System.assertEquals(4, 5);
            }
        }

        // Now repeat this action and ensure that two new identical Opportunities aren't created in our list
        reader = new XmlStreamReader(ORDER_XML_STR);
        bParseTest = new BPTXmlParser(reader, '2343244');
        Opportunity[] oList2 = bParseTest.getOpptyMap().values();
        System.assertEquals(oList2.size(), 0);
    }
    
    /* Test creating 2 Opportunities, each with null seat assignment */
    @isTest
    static private void xmlOrderParserTestNullSeats() {
        // Let's first process our actual Events into Campaigns
        XmlStreamReader reader = new XmlStreamReader(EVENT_XML_STR);
        BPTXmlParser bParseTest = new BPTXmlParser(reader, null);

        System.assertEquals(2, bParseTest.getEventStringList().size());
        System.assertEquals('Test Developer Event 1^http://www.brownpapertickets.com/event/2343244^2343244', bParseTest.getEventStringList()[0]);
        System.assertEquals('Test Developer Event 2^http://www.brownpapertickets.com/event/42344^42344', bParseTest.getEventStringList()[1]);

        reader = new XmlStreamReader(EVENT_XML_STR);
        BPTXmlParser bParseTest2 = new BPTXmlParser(reader, null);

        // Now insert a Campaign for our Opportunities to be linked to
        Campaign existingCampaign = new Campaign(Name='Test Developer Event 1', Event_Number__c='2343244', Event_Link__c='http://www.brownpapertickets.com/event/2343244');
        insert existingCampaign;
        System.assertNotEquals(null, existingCampaign.Id);

        // Now let's process the orders from these Events into Opportunities
        reader = new XmlStreamReader(ORDER_XML_STR2);
        bParseTest = new BPTXmlParser(reader, '2343244');
        Opportunity[] oList = bParseTest.getOpptyMap().values();

        System.assertEquals(oList.size(), 1);
        insert oList;
        idSet.add(oList[0].Id);

        for (Opportunity o: [select Id,
                                    Name,
                                    Street_Address__c,
                                    City__c,
                                    Zip_Code__c,
                                    BPT_Email__c,
                                    Phone_Number__c,
                                    TotalOpportunityQuantity,
                                    BPT_Event_Id__c,
                                    Seat_Location__c
                              from Opportunity
                              where Id in :idSet]) {
            System.assertNotEquals(o.Id, null);
            System.assertEquals(o.Name, 'Test Developer Event 1 - Bob Tungsten');
            System.assertEquals(o.Street_Address__c, '23232 Fleet Street');
            System.assertEquals(o.City__c, 'Santa Clara');
            System.assertEquals(o.Zip_Code__c, '94105');
            System.assertEquals(o.BPT_Email__c, 'btung@yahoo.com');
            System.assertEquals(o.Phone_Number__c, '4155555555');
            System.assertEquals(o.TotalOpportunityQuantity, 10);
            System.assertEquals(o.Seat_Location__c, 'Section 1,Row N/A,Seat N/A');
            System.assertEquals(o.BPT_Event_Id__c, '2343244');
        }
    }

    /* Test creating 3 Opportunities, each with different seat assignments */
    @isTest
    static private void xmlOrderParserTestMixedSeats() {
        // Let's first process our actual Events into Campaigns
        XmlStreamReader reader = new XmlStreamReader(EVENT_XML_STR);
        BPTXmlParser bParseTest = new BPTXmlParser(reader, null);

        System.assertEquals(2, bParseTest.getEventStringList().size());
        System.assertEquals('Test Developer Event 1^http://www.brownpapertickets.com/event/2343244^2343244', bParseTest.getEventStringList()[0]);
        System.assertEquals('Test Developer Event 2^http://www.brownpapertickets.com/event/42344^42344', bParseTest.getEventStringList()[1]);

        reader = new XmlStreamReader(EVENT_XML_STR);
        BPTXmlParser bParseTest2 = new BPTXmlParser(reader, null);

        // Now insert a Campaign for our Opportunities to be linked to
        Campaign existingCampaign = new Campaign(Name='Test Developer Event 1', Event_Number__c='2343244', Event_Link__c='http://www.brownpapertickets.com/event/2343244');
        insert existingCampaign;
        System.assertNotEquals(null, existingCampaign.Id);

        // Now let's process the orders from these Events into Opportunities
        reader = new XmlStreamReader(ORDER_XML_STR3);
        bParseTest = new BPTXmlParser(reader, '2343244');
        Opportunity[] oList = bParseTest.getOpptyMap().values();

        System.assertEquals(oList.size(), 1);
        insert oList;
        idSet.add(oList[0].Id);

        oList = [select Id,
                        Name,
                        Street_Address__c,
                        City__c,
                        Zip_Code__c,
                        BPT_Email__c,
                        Phone_Number__c,
                        TotalOpportunityQuantity,
                        BPT_Event_Id__c,
                        Seat_Location__c
                  from Opportunity
                  where Id in :idSet];

        for (Integer i=0; i<oList.size(); i++) {
            System.assertNotEquals(oList[i].Id, null);
            System.assertEquals(oList[i].Name, 'Test Developer Event 1 - Bob Tungsten');
            System.assertEquals(oList[i].Street_Address__c, '23232 Fleet Street');
            System.assertEquals(oList[i].City__c, 'Santa Clara');
            System.assertEquals(oList[i].Zip_Code__c, '94105');
            System.assertEquals(oList[i].BPT_Email__c, 'btung@yahoo.com');
            System.assertEquals(oList[i].Phone_Number__c, '4155555555');
            System.assertEquals(oList[i].TotalOpportunityQuantity, 15.00);
            System.assertEquals(oList[i].BPT_Event_Id__c, '2343244');
        }

        System.assertEquals(oList[0].Seat_Location__c, 'Section 2,Row C,Seat 33;Section N/A,Row N/A,Seat N/A;Section 2,Row E,Seat 44');
    }
}