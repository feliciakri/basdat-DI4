<?php
    /*session_start();
    if (!isset($_SESSION['loggeduser'])) {
        header('location: login');
    }
    
    include('dbconnect.php');

	$nomoriduser = $_SESSION['loggedusernumber'];*/
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>TokoKeren - Dinego Aja Shay, Pasti Cincay!</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="http://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link href="src/img/favicon.ico?" rel="icon" type="image/x-icon">
    <link type="text/css" rel="stylesheet" href="libs/bootstrap/dist/css/bootstrap.min.css">
    <link type="text/css" rel="stylesheet" href="libs/materialize/css/materialize.min.css"  media="screen,projection"/>
    <link rel="stylesheet" type="text/css" href="src/css/style.css">
    <link rel="stylesheet" type="text/css" href="src/css/navbar.css">
    <!-- insert more css file here -->

</head>
<body>
		<?php
            /*include('navbar.php');*/
        ?>	
    <div class="container">
        <div class="row">
            <div class="wrap">
                <!--<h1>YOUR CART</h1>
                <div class="divider"></div>-->
            </div>
            <div class="row">
                <div class="wrap cf">
  <div class="heading cf">
    <h1>My Cart</h1>
    <a href="#" class="continue">Continue Shopping</a>
  </div>
  <div class="cart">
<!--    <ul class="tableHead">
      <li class="prodHeader">Product</li>
      <li>Quantity</li>
      <li>Total</li>
       <li>Remove</li>
    </ul>-->
    <ul class="cartWrap">
      <li class="items odd">
        
    <div class="infoWrap"> 
        <div class="cartSection">
        <img src="http://lorempixel.com/output/technics-q-c-300-300-4.jpg" alt="" class="itemImg" />
          <p class="itemNumber">#QUE-007544-002</p>
          <h3>Item Name 1</h3>
        
           <p> <input type="text"  class="qty" placeholder="3"/> x Rp50000,-</p>
        
          <p class="stockStatus"> In Stock</p>
        </div>  
    
        
        <div class="prodTotal cartSection">
          <p>Rp150000,-</p>
        </div>
              <div class="cartSection removeWrap">
           <a href="#" class="remove">x</a>
        </div>
      </div>
      </li>
      <li class="items even">
        
       <div class="infoWrap"> 
        <div class="cartSection">
         
        <img src="http://lorempixel.com/output/technics-q-c-300-300-4.jpg" alt="" class="itemImg" />
          <p class="itemNumber">#QUE-007544-002</p>
          <h3>Item Name 1</h3>
        
           <p> <input type="text"  class="qty" placeholder="3"/> x Rp50000,-</p>
        
          <p class="stockStatus"> In Stock</p>
        </div>  
    
        
        <div class="prodTotal cartSection">
          <p>Rp150000,-</p>
        </div>
              <div class="cartSection removeWrap">
           <a href="#" class="remove">x</a>
        </div>
      </div>
      </li>
      
            <li class="items odd">
             <div class="infoWrap"> 
        <div class="cartSection">
            
        <img src="http://lorempixel.com/output/technics-q-c-300-300-4.jpg" alt="" class="itemImg" />
          <p class="itemNumber">#QUE-007544-002</p>
          <h3>Item Name 1</h3>
        
           <p> <input type="text"  class="qty" placeholder="3"/> x Rp50000,-</p>
        
          <p class="stockStatus out"> Out of Stock</p>
        </div>  
    
        
        <div class="prodTotal cartSection">
          <p>Rp150000,-</p>
        </div>
                    <div class="cartSection removeWrap">
           <a href="#" class="remove">x</a>
        </div>
              </div>
      </li>
      <li class="items even">
       <div class="infoWrap"> 
        <div class="cartSection info">
             
        <img src="http://lorempixel.com/output/technics-q-c-300-300-4.jpg" alt="" class="itemImg" />
          <p class="itemNumber">#QUE-007544-002</p>
          <h3>Item Name 1</h3>
        
          <p> <input type="text"  class="qty" placeholder="3"/> x Rp50000,-</p>
        
          <p class="stockStatus"> In Stock</p>
          
        </div>  
    
        
        <div class="prodTotal cartSection">
          <p>Rp150000,-</p>
        </div>
    
            <div class="cartSection removeWrap">
           <a href="#" class="remove">x</a>
        </div>
         </div>
         <div class="special"><div class="specialContent">Jangan lupa dinego shay</div></div>
      </li>
      
      
      <!--<li class="items even">Item 2</li>-->
 
    </ul>
  </div>
  
  <div class="promoCode"><label for="promo">Have A Promo Code?</label><input type="text" name="promo" placholder="Enter Code" />
  <a href="#" class="btn"></a></div>
  
  <div class="subtotal cf">
    <ul>
      <li class="totalRow"><span class="label">Subtotal</span><span class="value">Rp350000,-</span></li>
      
          <li class="totalRow"><span class="label">Shipping</span><span class="value">Rp50000,-</span></li>
      
            <li class="totalRow"><span class="label">Tax</span><span class="value">Rp40000,-</span></li>
            <li class="totalRow final"><span class="label">Total</span><span class="value">Rp440000,-</span></li>
      <li class="totalRow"><a href="#" class="btn continue">Checkout</a></li>
    </ul>
  </div>
</div>
            </div><!--End of row1-->
            <div class="row">
            </div><!--End of row1-->
            <div class="row">
            </div><!--End of row1-->
        </div>
    </div>
	
	
	
    <script type="text/javascript" src="libs/jquery/dist/jquery.min.js"></script>
    <script type="text/javascript" src="src/js/jquery.menu-aim.js"></script> <!-- menu aim -->
    <script type="text/javascript" src="src/js/script.js"></script>
    <script type="text/javascript" src="libs/bootstrap/dist/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="libs/materialize/js/materialize.min.js"></script>
    <!-- insert more js file here -->
</body>
</html>		