xquery version "3.0";
            
module namespace user="http://parsqube.de/ifv/user-admin/user";

import module namespace templates="http://exist-db.org/xquery/templates";

import module namespace functx = "http://www.functx.com";

declare function user:get-username($node as node(), $model as map(*), $target-attr) {
    let $username := request:get-parameter('username',())
    return
    if ($target-attr) then
        element { node-name($node) } {
            $node/@*,
            attribute { $target-attr } { $username },
            templates:process($node/*, $model)
        }
    else
        <label for="username">Username: {$username}</label>
};

declare function user:get-email($node as node(), $model as map(*)){
    <input type="text" name="email" id="email" class="form-control" placeholder="email" value="{sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/contact/email"))}" onkeyup="checkEmail(); return false;" onfocus="checkEmail(); return false;"/>
};

declare function user:get-firstname($node as node(), $model as map(*)){
    <input type="text" name="firstname" id="firstname" class="form-control" placeholder="firstname" value="{sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/namePerson/first"))}"/>
};

declare function user:get-lastname($node as node(), $model as map(*)){
    <input type="text" name="lastname" id="lastname" class="form-control" placeholder="lastname" value="{sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/namePerson/last"))}"/>
};

declare function user:get-fullname($node as node(), $model as map(*)){
    <input type="text" name="fullname" id="fullname" class="form-control" placeholder="fullname" value="{sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/namePerson"))}"/>
};

declare function user:get-description($node as node(), $model as map(*)){
    <textarea name="description" id="description" class="form-control" placeholder="This person is lazy, who has no description left.">{sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://exist-db.org/security/description"))}</textarea>
};

declare function user:get-language($node as node(), $model as map(*)){
    if (sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/pref/language")) eq 'DE')
    then
    <select name="language" id="language" class="form-control input-sm">
        <option selected="selected">DE</option>
        <option>EN</option>
    </select>
    else
        <select name="language" id="language" class="form-control input-sm">
        <option>DE</option>
        <option selected="selected">EN</option>
    </select>
};

declare function user:get-timezone($node as node(), $model as map(*)){
    if (sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/pref/timezone")) eq 'CET')
    then
    <select name="timezone" id="timezone" class="form-control input-sm">
        <option selected="selected">CET</option>
        <option>GMT</option>
    </select>
    else
    <select name="timezone" id="timezone" class="form-control input-sm">
        <option>CET</option>
        <option selected="selected">GMT</option>
    </select>   
};

declare function user:get-groups($node as node(), $model as map(*)){
  <select class="form-control input-sm" id="usergroup" name="usergroup" required="required">
    {
     let $groups := sm:list-groups()
     for $group in $groups
     return
         <option>{$group}</option>
    }
  </select>
};

declare function user:list-users($node as node(), $model as map(*)){
<table class="table table-bordered text-center">
    <tr>
        <th class="text-center">username</th><th class="text-center">group</th>
        {for $key in sm:get-account-metadata-keys()
            return
                <th class="text-center">{functx:substring-after-last($key,"/")}</th>
        }
        <th class="text-center">edit</th>
        <th class="text-center">delete</th>
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
    <td><a href="edit-user.html?username={escape-uri($user, true())}" target="_blank" class="btn btn-primary">edit</a></td>
    <td><a href="delete-user.html?username={escape-uri($user, true())}" class="btn btn-danger">delete</a></td>
</tr>}
</table>
};

declare function user:save-user($username as xs:string, $email as xs:string, $firstname as xs:string, $lastname as xs:string, $fullname as xs:string, $language as xs:string, $timezone as xs:string, $description as xs:string, $password as xs:string){
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/namePerson/first"),$firstname),
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/namePerson/last"),$lastname),
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/namePerson"),$fullname),
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/contact/email"),$email),
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/pref/language"),$language),
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/pref/timezone"),$timezone),
    sm:set-account-metadata($username,xs:anyURI("http://exist-db.org/security/description"),$description),
    if(not(empty($password))) then (
        if(not($password eq '')) then (sm:passwd($username,$password))
        else()
        )
    else ()
};

declare function user:create-user($username as xs:string,$password as xs:string,$group as xs:string,$email as xs:string, $firstname as xs:string, $lastname as xs:string, $fullname as xs:string, $language as xs:string, $timezone as xs:string, $description as xs:string){
  sm:create-account($username,$password,$group,()),
  user:save-user($username,$email,$firstname,$lastname,$fullname,$language,$timezone,$description,$password)
};

declare function user:create-user($node as node(), $model as map(*)){
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
    if(sm:user-exists($username)) then
        <div>
        <div class="alert alert-success">New user "{$username}" has been created. </div>
        <a href="add-user.html" class="btn btn-primary">Create another new user.</a><a href="list-users.html" style="margin-left: 10px" class="btn btn-info">Back to user list.</a>
        </div>
    else
        <div>
        <div class="alert alert-danger">New user "{$username}" has not been created. </div>
        <a href="add-user.html" class="btn btn-primary">Try again.</a>
        </div>
};

declare function user:delete-user($node as node(), $model as map(*)){
    sm:remove-account(request:get-parameter("username",())),
    let $username := request:get-parameter("username",())
    return
    if(sm:user-exists($username)) then
    <div>
        <div class="alert alert-danger">User "{$username}" has not been deleted.</div>
        <a href="list-users.html" class="btn btn-info">Back to user list and try again.</a>
    </div>
    else
    <div>
        <div class="alert alert-success">User "{$username}" has been deleted.</div>
        <a href="list-users.html" class="btn btn-info">Back to user list.</a>
    </div>
};
