#!/usr/bin/ruby
#
# Copyright 2017 Istio Authors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

require 'webrick'
require 'json'
require 'net/http'

if ARGV.length < 1 then
    puts "usage: #{$PROGRAM_NAME} port"
    exit(-1)
end

port = Integer(ARGV[0])

server = WEBrick::HTTPServer.new :BindAddress => '0.0.0.0', :Port => port

trap 'INT' do server.shutdown end

server.mount_proc '/health' do |req, res|
    res.status = 200
    res.body = {'status' => 'Details is healthy'}.to_json
    res['Content-Type'] = 'application/json'
end

server.mount_proc '/details' do |req, res|

    opa_uri = URI.parse('http://opa:8181/v1/data/example/allow')
    opa_conn = Net::HTTP.new(opa_uri.host, opa_uri.port)
    opa_req = Net::HTTP::Post.new(opa_uri.request_uri)
    user = req.cookies.find { |c| c.name == 'user' }
    user_id = nil
    if not user.nil? then
        user_id = user.value
    end
    opa_req.body = {
        'input' => {
            'method' => req.request_method,
            'path' => req.path.tr('/', '').split('/'),
            'user' => user_id
        }
    }.to_json
    opa_res = opa_conn.request(opa_req)
    forbid = true
    case opa_res
    when Net::HTTPSuccess then
        body = JSON.parse(opa_res.body)
        if body.key?("result") and body["result"] then
            forbid = false
        end
    end
    if forbid then
        res.body = {
            'error': 'request rejected by administrative policy'
        }.to_json
        res['Content-Type'] = 'application/json'
        res.status = 403
    else
        pathParts = req.path.split('/')
        begin
            id = Integer(pathParts[-1])
            details = get_book_details(id)
            res.body = details.to_json
            res['Content-Type'] = 'application/json'
        rescue
            res.body = {'error' => 'please provide numeric product id'}.to_json
            res['Content-Type'] = 'application/json'
            res.status = 400
        end
    end
end

# TODO: provide details on different books.
def get_book_details(id)
    return {
        'id' => id,
        'author': 'William Shakespeare',
        'year': 1595,
        'type' => 'paperback',
        'pages' => 200,
        'publisher' => 'PublisherA',
        'language' => 'English',
        'ISBN-10' => '1234567890',
        'ISBN-13' => '123-1234567890'
    }
end

server.start
