<#import "base.ftlh" as base>
<@base.display_page>
<h1>Login</h1>
<#if error??>
<div id='error' class='bar bar-error'>
	Error: ${error}
</div>
</#if>
	<form method="POST" action="/login" class="pure-form pure-form-stacked">
	<input name="username" placeholder="username">
	<input name="password" placeholder="password" type="password">
	<input type="submit">
	</form>
</@base.display_page>