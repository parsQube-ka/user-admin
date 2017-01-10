xquery version "3.0";
            
module namespace user="http://parsqube.de/ifv/user-admin/user";

import module namespace functx = "http://www.functx.com";

declare function user:list-users($node as node(), $model as map(*)){
<table class="table table-bordered">
    <tr>
        <th>username</th><th>group</th>
        {for $key in sm:get-account-metadata-keys()
            return
                <th>{functx:substring-after-last($key,"/")}</th>
        }
        <th>edit email</th>
    </tr>
{let $users := sm:list-users()
for $user in $users
return <tr>
    <td>{$user}</td><td>{sm:get-user-groups($user)}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/namePerson/friendly"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/namePerson/first"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/namePerson/last"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/namePerson"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/contact/email"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/contact/country/home"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/pref/language"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/pref/timezone"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://exist-db.org/security/description"))}</td>
    <td><a href="edit-user.html?username={$user}" class="btn btn-primary">edit</a></td>
</tr>}
</table>
};

declare function user:get-username($node as node(), $model as map(*)){
  <label for="username">Username: {request:get-parameter('username',())}</label>
};

declare function user:get-email($node as node(), $model as map(*)){
    <input type="text" name="email" id="email" class="input-xlarge form-control" placeholder="email" value="{sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/contact/email"))}"/>
};

declare function user:save-user($username as xs:string, $email as xs:string){
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/contact/email"),$email),
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="list-users.html"/>
    </dispatch>
};