xquery version "3.0";

import module namespace user="http://parsqube.de/ifv/user-admin/user" at "/db/apps/user-admin2/modules/user.xqm";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

let $username := request:get-parameter("username",())
let $group := request:get-parameter("usergroup",())
let $firstname := request:get-parameter("firstname",())
let $lastname := request:get-parameter("lastname",())
let $fullname := request:get-parameter("fullname",())
let $email := request:get-parameter("email",())
let $language := request:get-parameter("language",())
let $timezone := request:get-parameter("timezone",())
let $password := request:get-parameter("password1",())
let $description := request:get-parameter("description",())
return
    user:create-user($username,$password,$group,$email,$firstname,$lastname,$fullname,$language,$timezone,$description),

let $username := request:get-parameter("username",())
return
    <div xmlns="http://www.w3.org/1999/xhtml" data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
{
if(sm:user-exists($username)) then
        <p class="success">New user "{$username}" has been created. </p>
    else
        <p class="danger">New user "{$username}" has not been created. </p>
}
    </div>