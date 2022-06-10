<#import "base.ftlh" as base>
<@base.display_page>
<h1>Register</h1>
<#if error??>
<div id='error' class='bar bar-error'>
	Error: ${error}
</div>
</#if>
<#if password??>
	<div id='success' class='bar bar-success'>
		Successful registration, your password is: ${password}.  Please record it, it will not be displayed again.
	</div>
<#else>
	<form method="POST" action="/register" class="pure-form pure-form-stacked">
	<input name="username" pattern="[a-z0-9]+" placeholder="username">
	<input type="submit">
	</form>
</#if>
</@base.display_page>