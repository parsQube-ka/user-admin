xquery version "3.0";

import module namespace app="http://parsqube.de/ifv/user-admin/templates" at "/db/apps/user-admin2/modules/app.xqm";
import module namespace login="http://parsqube.de/ifv/user-admin/login" at "/db/apps/user-admin2/modules/login.xqm";
import module namespace user="http://parsqube.de/ifv/user-admin/user" at "/db/apps/user-admin2/modules/user.xqm";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if (not(sm:id()//sm:group[. = 'dba'])) then (login:login($exist:path,sm:id())[0]) else (),

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>

else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>

(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>

else if (not(sm:id()//sm:group[. = 'dba'])) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="login.html"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                    <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
                    <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                    <set-header name="Cache-Control" value="no-cache"/>
                </forward>
            </view>
        </dispatch>

else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                    <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
                    <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                    <set-header name="Cache-Control" value="no-cache"/>
            </forward>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>

else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
