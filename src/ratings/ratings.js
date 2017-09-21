// Copyright 2017 Istio Authors
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

var http = require('http')
var dispatcher = require('httpdispatcher')
var request = require('request')

var port = parseInt(process.argv[2])

/**
 * We default to using mongodb, if DB_TYPE is not set to mysql.
 */
if (process.env.SERVICE_VERSION === 'v2') {
  if (process.env.DB_TYPE === 'mysql') {
    var mysql = require('mysql')
    var hostName = process.env.MYSQL_DB_HOST
    var portNumber = process.env.MYSQL_DB_PORT
    var username = process.env.MYSQL_DB_USER
    var password = process.env.MYSQL_DB_PASSWORD
  } else {
    var MongoClient = require('mongodb').MongoClient
    var url = process.env.MONGO_DB_URL
  }
}


function parseCookies (request) {
    var list = {},
        rc = request.headers.cookie;

    rc && rc.split(';').forEach(function( cookie ) {
        var parts = cookie.split('=');
        list[parts.shift().trim()] = decodeURI(parts.join('='));
    });

    return list;
}


dispatcher.onGet(/^\/ratings\/[.+]*/, function(req, res) {


  var cookies = parseCookies(req)

  var productIdStr = req.url.split('/').pop()
  var productId = parseInt(productIdStr)

    request.post('http://opa:8181/v1/data/example/allow',
        {
            json: {
                input: {
                    source: "reviews",
                    target: "ratings",
					user: cookies.user,
                    method: "GET",
                    path: ["ratings", productIdStr]
                }
            }
        }, function(opa_error, opa_response, opa_body) {

            if (!opa_error && opa_response.statusCode == 200 && opa_body.result == true) {
                return ratingsGet(req, res)
            } else {
                res.writeHead(403, {'Content-type': 'application/json'})
                res.end(JSON.stringify({"error": "not authorized"}))
            }

        })
})

function ratingsGet(req, res) {
  var productId = req.url.split('/').pop()
  res.writeHead(200, {'Content-type': 'application/json'})
  res.end(JSON.stringify(getLocalReviews(productId)))
}

dispatcher.onGet('/health', function (req, res) {
  res.writeHead(200, {'Content-type': 'application/json'})
  res.end(JSON.stringify({status: 'Ratings is healthy'}))
})

function getLocalReviews (productId) {
  return {
    id: productId,
    ratings: {
      'Reviewer1': 1,
      'Reviewer2': 5
    }
  }
}

function handleRequest (request, response) {
  try {
    console.log(request.method + ' ' + request.url)
    dispatcher.dispatch(request, response)
  } catch (err) {
    console.log(err)
  }
}

var server = http.createServer(handleRequest)

server.listen(port, function () {
  console.log('Server listening on: http://0.0.0.0:%s', port)
})
