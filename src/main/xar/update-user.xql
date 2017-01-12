xquery version "3.0";

import module namespace user="http://parsqube.de/ifv/user-admin/user" at "/db/apps/user-admin2/modules/user.xqm";

let $username := request:get-parameter("username",())
return (
 user:save-user($username,request:get-parameter("email",()),request:get-parameter("firstname",()),request:get-parameter("lastname",()),request:get-parameter("fullname",()),request:get-parameter("language",()),request:get-parameter("timezone",()),request:get-parameter("description",()),request:get-parameter("password1",()),request:get-parameter("availableGroups",()),request:get-parameter("userGroups",())),
 response:redirect-to(xs:anyURI("edit-user.html?username=" || escape-uri($username, true())))

)