<#import "base.ftlh" as base>
<@base.display_page>
<h1>login4shell</h1>
<p><b>Login and get a shell!</b></p>
<p>Welcome to the simple login service.  We've been hard at work making it as secure as possible and keeping up with the latest trends.</p>
<p><b>Changelog</b></p>
<ul>
<li>Temporarily removed support for sub-users
<li>Added support for sub-users in the format <i>user+subuser</i>.  Use the same password to login.
<li>Patched logger for <a href='https://en.wikipedia.org/wiki/Log4Shell'>Log4Shell</a>
</ul>
</@base.display_page>