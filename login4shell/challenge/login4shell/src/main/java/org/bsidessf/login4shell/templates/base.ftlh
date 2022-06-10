<#macro display_page>
<!DOCTYPE html>
<html>
	<title>login4shell</title>
	<link rel="stylesheet" href="https://unpkg.com/purecss@2.1.0/build/pure-min.css" integrity="sha384-yHIFVG6ClnONEA5yB5DJXfW2/KC173DIQrYoZMEtBvGzmf0PKiGyNEqe9N6BNDBH" crossorigin="anonymous">
	<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body {
	padding-left: 20px;
	padding-right: 20px;
}
.custom-menu-wrapper {
    background-color: #808080;
    margin-bottom: 2.5em;
    white-space: nowrap;
    position: relative;
}

.custom-menu {
    display: inline-block;
    width: auto;
    vertical-align: middle;
    -webkit-font-smoothing: antialiased;
}

.custom-menu .pure-menu-link,
.custom-menu .pure-menu-heading {
    color: white;
}

.custom-menu .pure-menu-link:hover,
.custom-menu .pure-menu-heading:hover {
    background-color: transparent;
}

.custom-menu-top {
    position: relative;
    padding-top: .5em;
    padding-bottom: .5em;
}

.custom-menu-brand {
    display: block;
    text-align: center;
    position: relative;
}

.custom-menu-toggle {
    width: 44px;
    height: 44px;
    display: block;
    position: absolute;
    top: 3px;
    right: 0;
    display: none;
}

.custom-menu-toggle .bar {
    background-color: white;
    display: block;
    width: 20px;
    height: 2px;
    border-radius: 100px;
    position: absolute;
    top: 22px;
    right: 12px;
    -webkit-transition: all 0.5s;
    -moz-transition: all 0.5s;
    -ms-transition: all 0.5s;
    transition: all 0.5s;
}

.custom-menu-toggle .bar:first-child {
    -webkit-transform: translateY(-6px);
    -moz-transform: translateY(-6px);
    -ms-transform: translateY(-6px);
    transform: translateY(-6px);
}

.custom-menu-toggle.x .bar {
    -webkit-transform: rotate(45deg);
    -moz-transform: rotate(45deg);
    -ms-transform: rotate(45deg);
    transform: rotate(45deg);
}

.custom-menu-toggle.x .bar:first-child {
    -webkit-transform: rotate(-45deg);
    -moz-transform: rotate(-45deg);
    -ms-transform: rotate(-45deg);
    transform: rotate(-45deg);
}

.custom-menu-screen {
    background-color: rgba(0, 0, 0, 0.5);
    -webkit-transition: all 0.5s;
    -moz-transition: all 0.5s;
    -ms-transition: all 0.5s;
    transition: all 0.5s;
    height: 3em;
    width: 70em;
    position: absolute;
    top: 0;
    z-index: -1;
}

.custom-menu-tucked .custom-menu-screen {
    -webkit-transform: translateY(-44px);
    -moz-transform: translateY(-44px);
    -ms-transform: translateY(-44px);
    transform: translateY(-44px);
}

@media (max-width: 62em) {

    .custom-menu {
        display: block;
    }

    .custom-menu-toggle {
        display: block;
        display: none\9;
    }

    .custom-menu-bottom {
        position: absolute;
        width: 100%;
        border-top: 1px solid #eee;
        background-color: #808080\9;
        z-index: 100;
    }

    .custom-menu-bottom .pure-menu-link {
        opacity: 1;
        -webkit-transform: translateX(0);
        -moz-transform: translateX(0);
        -ms-transform: translateX(0);
        transform: translateX(0);
        -webkit-transition: all 0.5s;
        -moz-transition: all 0.5s;
        -ms-transition: all 0.5s;
        transition: all 0.5s;
    }

    .custom-menu-bottom.custom-menu-tucked .pure-menu-link {
        -webkit-transform: translateX(-140px);
        -moz-transform: translateX(-140px);
        -ms-transform: translateX(-140px);
        transform: translateX(-140px);
        opacity: 0;
        opacity: 1\9;
    }

    .pure-menu-horizontal.custom-menu-tucked {
        z-index: -1;
        top: 45px;
        position: absolute;
        overflow: hidden;
    }

}

.bar {
  padding: 10px;
  margin: 10px;
  color: #333;
  background: #fafafa;
  border: 1px solid #ccc;
}

.bar-info {
  color: #204a8e;
  background: #c9ddff;
  border: 1px solid #4c699b;
}
.bar-success {
  color: #2b7515;
  background: #ecffd6;
  border: 1px solid #617c42;
}
.bar-warn {
  color: #756e15;
  background: #fffbd1;
  border: 1px solid #87803e;
}
.bar-error {
  color: #ba3939;
  background: #ffe0e0;
  border: 1px solid #a33a3a;
}
</style>
	<body>
		<div class="custom-menu-wrapper">
		    <div class="pure-menu custom-menu custom-menu-top">
		        <a href="#" class="pure-menu-heading custom-menu-brand">login4shell</a>
		    </div>
		    <div class="pure-menu pure-menu-horizontal pure-menu-scrollable custom-menu custom-menu-bottom custom-menu-tucked" id="tuckedMenu">
		        <div class="custom-menu-screen"></div>
		        <ul class="pure-menu-list">
		            <li class="pure-menu-item"><a href="/" class="pure-menu-link">Home</a></li>
		            <#if !(loggedin!false)>
		            	<li class="pure-menu-item"><a href="/login" class="pure-menu-link">Login</a></li>
		            	<li class="pure-menu-item"><a href="/register" class="pure-menu-link">Register</a></li>
		            <#else>
		            	<li class="pure-menu-item"><a href="/flag" class="pure-menu-link">Flag</a></li>
		            	<li class="pure-menu-item"><a href="/logout" class="pure-menu-link">Logout</a></li>
		            </#if>
		        </ul>
		    </div>
		</div>
		<#nested>
	</body>
</html>
</#macro>