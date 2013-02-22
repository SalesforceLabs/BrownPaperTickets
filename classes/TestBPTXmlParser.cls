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
private class TestBPTXmlParser {
    private static final String ORDER_XML_STR = '<document>' +
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
                                                        '<ticket_number>A22647605</ticket_number>' +
                                                        '<section></section>' +
                                                        '<row></row>' +
                                                        '<seat></seat>' +
                                                     '</item>' +
                                                   '</document>';

    private static final String EVENT_XML_STR = '<document>' +
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
    static private void xmlOrderParserTest() {
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
        Set<Id> idSet = new Set<Id>();

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
                                    BPT_Event_Id__c
                              from Opportunity
                              where Id in :idSet]) {
            System.assertNotEquals(o.Id, null);
            System.assertEquals(o.Name, 'Test Developer Event 1 - Bob Tungsten');
            System.assertEquals(o.Street_Address__c, '23232 Fleet Street');
            System.assertEquals(o.City__c, 'Santa Clara');
            System.assertEquals(o.Zip_Code__c, '94105');
            System.assertEquals(o.BPT_Email__c, 'btung@yahoo.com');
            System.assertEquals(o.Phone_Number__c, '4155555555');
            System.assertEquals(o.TotalOpportunityQuantity, 5);
            System.assertEquals(o.BPT_Event_Id__c, '2343244');
        }

        // Now repeat this action and ensure that two new identical Opportunities aren't created in our list
        reader = new XmlStreamReader(ORDER_XML_STR);
        bParseTest = new BPTXmlParser(reader, '2343244');
        Opportunity[] oList2 = bParseTest.getOpptyMap().values();
        System.assertEquals(oList2.size(), 0);
    }
}