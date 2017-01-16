xquery version "3.0";

module namespace login="http://parsqube.de/ifv/user-admin/login";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace session="http://exist-db.org/xquery/session";

import module namespace config="http://parsqube.de/ifv/user-admin/config" at "/db/apps/user-admin2/modules/config.xqm";
import module namespace functx = "http://www.functx.com";

declare %templates:wrap
function login:username($node as node(), $model as map(*), $username as xs:string*) {
  attribute value {$username}
};

declare %templates:wrap
function login:password($node as node(), $model as map(*), $password as xs:string*) {
  attribute value {$password}
};

declare function login:error($node as node(), $model as map(*)) {
  let $error := request:get-attribute('login-error')
  return if (exists($error))
    then element {node-name($node)} { $node/@*, $error }
    else ()
};

declare function login:login($exist-path,$id){
    let $username := request:get-parameter("username",())
    let $password := request:get-parameter("password",())
    return
    if($id//group[. = 'dba']) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="list-users.html"/>
    </dispatch>
    else
        if(empty($username)) then (
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <redirect url="login.html"/>
            </dispatch>    
            )
    else if(xmldb:login($config:app-root,$username,$password,true())) then (
        if(not(sm:get-user-groups($username) = 'dba')) then (request:set-attribute('login-error', 'Please login with dba account.'))
        else(
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <redirect url="list-users.html"/>
            </dispatch> )
        )
    else (request:set-attribute('login-error', 'Login failed. Please try again with the right password.'))
};
