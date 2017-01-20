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
        <label for="username">Benutzername: {$username}</label>
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

declare function user:get-primary-group($node as node(), $model as map(*)){
    let $username := request:get-parameter('username',())
    let $primary := sm:get-user-primary-group($username)
    return
    <select class="form-control input-sm" name="primaryGroup" id="primaryGroup">
        {for $group in sm:list-groups()
        return
            if($primary eq $group) then (<option selected="selected">{$group}</option>)
            else(<option>{$group}</option>)
        }
    </select>
};

declare function user:get-language($node as node(), $model as map(*)){
    <select name="language" id="language" class="form-control input-sm">{
    let $user-language := sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/pref/language"))
    return
        if(empty($user-language))then(<option selected="selected" value="">Sprache auswählen</option>) 
        else (<option value="">Sprache auswählen</option>),
        let $user-language := sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/pref/language"))
        for $language in doc("/db/apps/user-admin2/resources/configuration/languages.xml")//language   
        return
        if(data($language/name) eq $user-language)
        then(<option selected="selected">{$language/name}</option>)
        else(<option>{$language/name}</option>)
    }
    </select>
};

declare function user:get-all-languages($node as node(), $model as map(*)){
    <select name="language" id="language" class="form-control input-sm">
        <option value="">Sprache auswählen</option>
        {for $language in doc("/db/apps/user-admin2/resources/configuration/languages.xml")//language 
        return
        <option>{$language/name}</option>}
    </select>
};

declare function user:get-timezone($node as node(), $model as map(*)){
    <select name="timezone" id="timezone" class="form-control input-sm">
    {
        let $user-timezone := sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/pref/timezone"))
        return
        if(empty($user-timezone)) then (<option selected="selected" value="">Zeitzone auswählen</option>)
        else(<option value="">Zeitzone auswählen</option>),
        let $user-timezone := sm:get-account-metadata(request:get-parameter('username',()),xs:anyURI("http://axschema.org/pref/timezone"))
        for $timezone in doc("/db/apps/user-admin2/resources/configuration/timezones.xml")//timezone
        return
            if(data($timezone/name) eq $user-timezone)
            then(<option selected="selected">{$timezone/name}</option>)
            else(<option>{$timezone/name}</option>)
    }
    </select>   
};

declare function user:get-all-timezones($node as node(), $model as map(*)){
    <select name="timezone" id="timezone" class="form-control input-sm">
        <option value="">Zeitzone auswählen</option>
        {
            for $timezone in doc("/db/apps/user-admin2/resources/configuration/timezones.xml")//timezone
            return
                <option>{$timezone/name}</option>
        }     
    </select>
};

declare function user:primary-group($node as node(), $model as map(*)){
  <select class="form-control input-sm" id="usergroup" name="usergroup">
    <option selected="selected" value="primary">Stellen Sie hier die primäre Gruppe ein</option>
    {
     let $groups := sm:list-groups()
     for $group in $groups
     return
         <option>{$group}</option>
    }
  </select>
};

declare function user:list-groups($node as node(), $model as map(*)){
    <select class="form-control" multiple="multiple" id="usergroups" name="usergroups" size="5">
    {
     let $groups := sm:list-groups()
     for $group in $groups
     return
         <option>{$group}</option>
    }
    </select>
};

declare function user:list-users($node as node(), $model as map(*)){

<table class="table table-striped table-bordered text-center" name="userlist" id="userlist">
    <thead>
    <tr>
        <th class="text-center">Benutzername</th>
        <th class="text-center">Primäre Gruppe</th>
        <th class="text-center">Benutzergruppen</th>
        <th class="text-center">vollständiger Name</th>
        <th class="text-center">E-Mail</th>
        <th class="text-center">Sprache</th>
        <th class="text-center">Zeitzone</th>
        <th class="text-center">Beschreibung</th>
        <th class="text-center">Aktion</th>
    </tr>
    </thead>
    <tbody>
{let $users := sm:list-users()
for $user in $users
return
    <tr>
    <td>{$user}</td>
    <td>{sm:get-user-primary-group($user)}</td>
    <td>{sm:get-user-groups($user)}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/namePerson"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/contact/email"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/pref/language"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://axschema.org/pref/timezone"))}</td>
    <td>{sm:get-account-metadata($user,xs:anyURI("http://exist-db.org/security/description"))}</td>
    <td><a href="edit-user.html?username={escape-uri($user, true())}" class="btn btn-primary">Bearbeiten</a>
    {if($user eq 'admin') then ()
    else if ($user eq xmldb:get-current-user()) then()
    else
    (<a style="margin-left: 10px" href="confirm-delete-user.html?username={escape-uri($user, true())}" class="btn btn-danger">Löschen</a>)}
</td></tr>}
    </tbody>
</table>
};

declare function user:save-user($username as xs:string, $email as xs:string, $firstname as xs:string, $lastname as xs:string, $fullname as xs:string, $language as xs:string, $timezone as xs:string, $description as xs:string, $password as xs:string, $add-to as xs:string*, $remove-from as xs:string*, $primary-group as xs:string){
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/namePerson/first"),$firstname),
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/namePerson/last"),$lastname),
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/namePerson"),$fullname),
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/contact/email"),$email),
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/pref/language"),$language),
    sm:set-account-metadata($username,xs:anyURI("http://axschema.org/pref/timezone"),$timezone),
    sm:set-account-metadata($username,xs:anyURI("http://exist-db.org/security/description"),$description),
    sm:set-user-primary-group($username,$primary-group),
    if(not(empty($add-to)))
    then(
        for $target in $add-to
        return
        sm:add-group-member($target,$username))
        else(),
    if(not(empty($remove-from)))
    then(
        for $target in $remove-from
        return
        sm:remove-group-member($target,$username))
        else(),    
    if(not(empty($password))) then (
        if(not($password eq '')) then (sm:passwd($username,$password))
        else()
        )
    else ()
};

declare function user:create-user($username as xs:string,$password as xs:string,$group as xs:string*,$groups as xs:string*,$email as xs:string, $firstname as xs:string, $lastname as xs:string, $fullname as xs:string, $language as xs:string, $timezone as xs:string, $description as xs:string, $add-to as xs:string*, $remove-from as xs:string*){
   
    if($group eq 'primary') then (
        sm:create-account($username,$password,$groups))
    else(
        sm:create-account($username,$password,$group,$groups)),
        user:save-user($username,$email,$firstname,$lastname,$fullname,$language,$timezone,$description,$password,$add-to,$remove-from,sm:get-user-primary-group($username))
    
};

declare function user:create-user($node as node(), $model as map(*)){
let $username := request:get-parameter("username",())
let $group := request:get-parameter("usergroup",())
let $groups := request:get-parameter("usergroups",())
let $firstname := request:get-parameter("firstname",())
let $lastname := request:get-parameter("lastname",())
let $fullname := request:get-parameter("fullname",())
let $email := request:get-parameter("email",())
let $language := request:get-parameter("language",())
let $timezone := request:get-parameter("timezone",())
let $password := request:get-parameter("password1",())
let $description := request:get-parameter("description",())
let $add-to := request:get-parameter("availableGroups",())
let $remove-from := request:get-parameter("userGroups",())
return
    user:create-user($username,$password,$group,$groups,$email,$firstname,$lastname,$fullname,$language,$timezone,$description,$add-to,$remove-from),
let $username := request:get-parameter("username",())
return
    if(sm:user-exists($username)) then
        <div>
            <div class="alert alert-success">Neuer Benutzer "{$username}" wurde erstellt. </div>
            <a href="add-user.html" class="btn btn-primary">Erstellen Sie einen neuen Benutzer.</a>
            <a href="list-users.html" style="margin-left: 10px" class="btn btn-info">Zurück zur Benutzerliste.</a>
            <a href="edit-user.html?username={$username}" style="margin-left: 10px" class="btn btn-warning">Etwas stimmt nicht? Direkt zum Bearbeiten des Benutzers "{$username}".</a>
        </div>
    else
        <div>
        <div class="alert alert-danger">Neuer Benutzer "{$username}" wurde nicht erstellt.</div>
        <a href="add-user.html" class="btn btn-primary">Versuch es noch einmal.</a>
        </div>
};

declare function user:delete-user($node as node(), $model as map(*)){
    sm:remove-account(request:get-parameter("username",())),
    let $username := request:get-parameter("username",())
    return
    if(sm:user-exists($username)) then
    <div>
        <div class="alert alert-danger">Benutzer "{$username}" wurde nicht gelöscht.</div>
        <a href="list-users.html" class="btn btn-info">Zurück zur Benutzerliste und versuchen Sie es erneut.</a>
    </div>
    else
    <div>
        <div class="alert alert-success">Benutzer "{$username}" wurde gelöscht.</div>
        <a href="list-users.html" class="btn btn-info">Zurück zur Benutzerliste.</a>
    </div>
};

declare function user:get-available-groups($node as node(), $model as map(*)){
    <select multiple="multiple" class="form-control" name="availableGroups" id="availableGroups">{
    let $username := request:get-parameter('username',())
    let $groups := sm:list-groups()
    let $usergroups := sm:get-user-groups($username)
    for $group in $groups
    return
        if(not(functx:is-value-in-sequence($group,$usergroups))) then
        <option>{$group}</option>
        else ()
    }
    </select>
};

declare function user:get-user-groups($node as node(), $model as map(*)){
    <select multiple="multiple" class="form-control" name="userGroups" id="userGroups">{
    let $username := request:get-parameter('username',())
    let $usergroups := sm:get-user-groups($username)
    for $group in $usergroups
    return
        <option>{$group}</option>
    }
    </select>
};

declare function user:confirm-delete-user($node as node(), $model as map(*)){
    let $username := request:get-parameter('username',())
    return
    <div>
        <div class="alert alert-danger">Möchten Sie wirklich löschen den Benutzer "{$username}" ?</div>
        <a href="delete-user.html?username={escape-uri($username, true())}" class="btn btn-danger">Löschen</a>
        <a href="list-users.html" class="btn btn-info" style="margin-left: 10px">Abbrechen</a>
    </div>
};

declare function user:get-logout($node as node(), $model as map(*)){
    if(sm:get-user-groups(xmldb:get-current-user()) = 'dba') then
    <li id="logout"><a href="logout.html?logout=1">Abmelden</a></li>
    else ()
};

declare function user:logout($node as node(),$model as map(*)){
    if(request:get-parameter('logout',()) eq '1') then (session:invalidate())
    else (),
    response:redirect-to(xs:anyURI("index.html"))
};
