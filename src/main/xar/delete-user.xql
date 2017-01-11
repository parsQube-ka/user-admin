xquery version "3.0";

sm:remove-account(request:get-parameter("username",())),

if(sm:user-exists(request:get-parameter("username",()))) then
    (<p>delete failed!</p>)
    else
    (<p>delete success!</p>)