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
public with sharing class BPTMockHttpRespGenerator implements HttpCalloutMock {
    private static final String XML_STR = '<?xml version=\"1.0\"?>' +
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

    public HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('https://www.brownpapertickets.com/api2/orderlist?id=12tstdvid3&account=testacct@emailaddy.com&event_id=888888',
                             req.getEndpoint());
        System.assertEquals('GET', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(XML_STR);
        res.setStatusCode(200);
        return res;
    }
}