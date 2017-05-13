$(document).ready(function () {
	function validatePassword()
	{
	  var a = document.forms["form-regis"]["password"].value;
	  var b = document.forms["form-regis"]["re-password"].value;
	  if(!(a == b))
	  {
	    alert("Password salah");
	    return false;
	  }
	  return true;
	}
});
