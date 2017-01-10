xquery version "3.0";

import module namespace config="http://parsqube.de/ifv/user-admin/config" at "config.xqm";

let $username := request:get-parameter('username',())
let $password := request:get-parameter('password',())
return
    if(empty($username)) then ()
    else if (empty($password)) then ()
    else let $result := xmldb:login($config:app-root,$username,$password,ture())
    return if($result) then <p> login success</p>
    else <p>login failed</p>