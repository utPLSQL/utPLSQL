var fs = require('fs');
var request = require('request');
const md5File = require('md5-file');

var url
if (process.env.COVERALLS_URL_BASE) {
	url = process.env.COVERALLS_URL_BASE+'/api/v1/jobs';
} else {
	url = 'https://coveralls.io/api/v1/jobs';
}

fs.readFile('../old_tests/coverage.json',function (err,data) {
	if (err) {
		return console.log(err);
	}
	req = JSON.parse(data);
	req.service_job_id = process.env.TRAVIS_JOB_ID;
	req.service_name = 'travis-ci';
	if (process.env.COVERALLS_REPO_TOKEN) {
		req.repo_token = process.env.COVERALLS_REPO_TOKEN;
	}

	for (var i in req.source_files) {
		req.source_files[i].source_digest = md5File.sync("../" + req.source_files[i].name);
	}

	var requestStr = JSON.stringify(req);

	request.post({url : url, form : { json:requestStr}}, function(err, response, body){process.stdout.write(body);});

});
