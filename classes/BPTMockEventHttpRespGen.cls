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
public with sharing class BPTMockEventHttpRespGen implements HttpCalloutMock {
    private static final String EVENT_XML_STR = '<document>' +
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

    public HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('https://www.brownpapertickets.com/api2/eventsales?id=12tstdvid3&account=testacct@emailaddy.com',
                             req.getEndpoint());
        System.assertEquals('GET', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(EVENT_XML_STR);
        res.setStatusCode(200);
        return res;
    }
}