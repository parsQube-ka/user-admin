xquery version "3.0";

import module namespace functx = "http://www.functx.com";

<table border="1">
    <tr>
        <th>username</th><th>group</th>
        {for $key in sm:get-account-metadata-keys()
            return
                <th>{functx:substring-after-last($key,"/")}</th>
        }
    </tr>
{let $users := sm:list-users()
for $user in $users
return <tr>
    <td>{$user}</td><td>{sm:get-user-groups($user)}</td>
{let $metadata-keys := sm:get-account-metadata-keys($user)
for $metadata-key in $metadata-keys
return
            <td>{$metadata-key},{sm:get-account-metadata($user,xs:anyURI($metadata-key))}</td>
}</tr>}
</table>
