xquery version "3.0";

module namespace login="http://parsqube.de/ifv/user-admin/login";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace session="http://exist-db.org/xquery/session";

import module namespace config="http://parsqube.de/ifv/user-admin/config" at "/db/apps/user-admin2/modules/config.xqm";


declare %templates:wrap
function login:username($node as node(), $model as map(*), $username as xs:string*) {
  attribute value {$username}
};

declare %templates:wrap
function login:password($node as node(), $model as map(*), $password as xs:string*) {
  attribute value {$password}
};

declare function login:login($exist-path,$id){
    (util:log('info', "try to login")),
    let $username := request:get-parameter("username",())
    let $password := request:get-parameter("password",())
    return
    if($id eq 'admin') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="list-users.html"/>
    </dispatch>
    else if(not($username eq 'admin')) then (util:log('info', "login as non-admin"))
    else if(xmldb:login($config:app-root,$username,$password,true())) then (
        util:log('info', "login successsful"),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="list-users.html"/>
    </dispatch>
    )
    else (util:log('info', "login not successsful"))
};
