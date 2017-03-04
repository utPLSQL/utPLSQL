var fs = require('fs');
var request = require('request');
const md5File = require('md5-file')

var repo_token = process.env.COVERALLS_REPO_TOKEN;
process.stdout.write("token");
process.stdout.write(process.env.COVERALLS_REPO_TOKEN);

if (process.env.COVERALLS_REPO_TOKEN) {


	fs.readFile('../tests/coverage.json',function (err,data) {  
		if (err) {
			return console.log(err);
		}
		req = JSON.parse(data);
		req.service_job_id = process.env.TRAVIS_JOB_ID;
		req.service_name = 'travis-ci';
		req.repo_token = process.env.COVERALLS_REPO_TOKEN;
		
		for (var i in req.source_files) {
			req.source_files[i].source_digest = md5File.sync("../" + req.source_files[i].name)
		}

		var url = 'https://coveralls.io/api/v1/jobs';

		var requestStr = JSON.stringify(req);
		//process.stdout.write(requestStr);
		
		request.post({url : url, form : { json:requestStr}}, function(err, response, body){process.stdout.write(body);});
		
		/*request.post({url : 'https://coveralls.io/api/v1/jobs', form : { json : '{"service_job_id":"207262924","service_name":"travis-ci"}'}}, function(err, response, body){
			
			process.stdout.write(err);
			process.stdout.write(response);
			process.stdout.write(body);
		});*/
		

	});
} 
else {
	throw "COVERALLS_REPO_TOKEN variable is not defined";
}