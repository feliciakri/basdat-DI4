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
                <h1>SHIPPED PRODUCT</h1>
                <div class="divider"></div>
            </div>
            <div class="row">
                <div class="col s12 cards-container">
                      <div class="row" id="toko-input">
                              <label for="ajax">Pick an Toko</label>
                              <input type="text" id="ajax" list="json-datalist" placeholder="e.g. datalist">
                              <datalist id="json-datalist"></datalist>
                              <div class="cd-dropdown-wrapper row">
                                    <a class="cd-dropdown-trigger" href="#">Kategori</a>
                                    <nav class="cd-dropdown">
                                        <h2>Title</h2>
                                        <a href="#0" class="cd-close">Close</a>
                                        <ul class="cd-dropdown-content">
                                            <li>
                                                <form class="cd-search">
                                                    <input type="search" placeholder="Search...">
                                                </form>
                                            </li>
                                            <li class="has-children">
                                                <a href="#">Clothing</a>

                                                <ul class="cd-secondary-dropdown is-hidden">
                                                    <li class="go-back"><a href="#0">Menu</a></li>
                                                    <li class="see-all"><a href="#">All Clothing</a></li>
                                                    <li class="has-children">
                                                        <a href="#">Accessories</a>

                                                        <ul class="is-hidden">
                                                            <li class="go-back"><a href="#0">Clothing</a></li>
                                                            <li class="see-all"><a href="#">All Accessories</a></li>
                                                            <li class="has-children">
                                                                <a href="#0">Beanies</a>

                                                                <ul class="is-hidden">
                                                                    <li class="go-back"><a href="#0">Accessories</a></li>
                                                                    <li class="see-all"><a href="#">All Benies</a></li>
                                                                    <li><a href="#">Caps &amp; Hats</a></li>
                                                                    <li><a href="#">Gifts</a></li>
                                                                    <li><a href="#">Scarves &amp; Snoods</a></li>
                                                                </ul>
                                                            </li>
                                                            <li class="has-children">
                                                                <a href="#0">Caps &amp; Hats</a>

                                                                <ul class="is-hidden">
                                                                    <li class="go-back"><a href="#0">Accessories</a></li>
                                                                    <li class="see-all"><a href="#">All Caps &amp; Hats</a></li>
                                                                    <li><a href="#">Beanies</a></li>
                                                                    <li><a href="#">Caps</a></li>
                                                                    <li><a href="#">Hats</a></li>
                                                                </ul>
                                                            </li>
                                                            <li><a href="#">Glasses</a></li>
                                                            <li><a href="#">Gloves</a></li>
                                                            <li><a href="#">Jewellery</a></li>
                                                            <li><a href="#">Scarves</a></li>
                                                        </ul>
                                                    </li>

                                                    <li class="has-children">
                                                        <a href="#">Bottoms</a>

                                                        <ul class="is-hidden">
                                                            <li class="go-back"><a href="#0">Clothing</a></li>
                                                            <li class="see-all"><a href="#">All Bottoms</a></li>
                                                            <li><a href="#">Casual Trousers</a></li>
                                                            <li class="has-children">
                                                                <a href="#0">Jeans</a>

                                                                <ul class="is-hidden">
                                                                    <li class="go-back"><a href="#0">Bottoms</a></li>
                                                                    <li class="see-all"><a href="#">All Jeans</a></li>
                                                                    <li><a href="#">Ripped</a></li>
                                                                    <li><a href="#">Skinny</a></li>
                                                                    <li><a href="#">Slim</a></li>
                                                                    <li><a href="#">Straight</a></li>
                                                                </ul>
                                                            </li>
                                                            <li><a href="#0">Leggings</a></li>
                                                            <li><a href="#0">Shorts</a></li>
                                                        </ul>
                                                    </li>

                                                    <li class="has-children">
                                                        <a href="#">Jackets</a>

                                                        <ul class="is-hidden">
                                                            <li class="go-back"><a href="#0">Clothing</a></li>
                                                            <li class="see-all"><a href="#">All Jackets</a></li>
                                                            <li><a href="#">Blazers</a></li>
                                                            <li><a href="#">Bomber jackets</a></li>
                                                            <li><a href="#">Denim Jackets</a></li>
                                                            <li><a href="#">Duffle Coats</a></li>
                                                            <li><a href="#">Leather Jackets</a></li>
                                                            <li><a href="#">Parkas</a></li>
                                                        </ul>
                                                    </li>

                                                    <li class="has-children">
                                                        <a href="#">Tops</a>

                                                        <ul class="is-hidden">
                                                            <li class="go-back"><a href="#0">Clothing</a></li>
                                                            <li class="see-all"><a href="#">All Tops</a></li>
                                                            <li><a href="#">Cardigans</a></li>
                                                            <li><a href="#">Coats</a></li>
                                                            <li><a href="#">Polo Shirts</a></li>
                                                            <li><a href="#">Shirts</a></li>
                                                            <li class="has-children">
                                                                <a href="#0">T-Shirts</a>

                                                                <ul class="is-hidden">
                                                                    <li class="go-back"><a href="#0">Tops</a></li>
                                                                    <li class="see-all"><a href="#">All T-shirts</a></li>
                                                                    <li><a href="#">Plain</a></li>
                                                                    <li><a href="#">Print</a></li>
                                                                    <li><a href="#">Striped</a></li>
                                                                    <li><a href="#">Long sleeved</a></li>
                                                                </ul>
                                                            </li>
                                                            <li><a href="#">Vests</a></li>
                                                        </ul>
                                                    </li>
                                                </ul> <!-- .cd-secondary-dropdown -->
                                            </li> <!-- .has-children -->

                                    



                                            <li class="has-children">
                                                <a href="#">Services</a>
                                                <ul class="cd-dropdown-icons is-hidden">
                                                    <li class="go-back"><a href="#0">Menu</a></li>
                                                    <li class="see-all"><a href="#">Browse Services</a></li>
                                                    <li>
                                                        <a class="cd-dropdown-item item-1" href="#">
                                                            <h3>Service #1</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-2" href="#">
                                                            <h3>Service #2</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-3" href="#">
                                                            <h3>Service #3</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-4" href="#">
                                                            <h3>Service #4</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-5" href="#">
                                                            <h3>Service #5</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-6" href="#">
                                                            <h3>Service #6</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-7" href="#">
                                                            <h3>Service #7</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-8" href="#">
                                                            <h3>Service #8</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-9" href="#">
                                                            <h3>Service #9</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-10" href="#">
                                                            <h3>Service #10</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-11" href="#">
                                                            <h3>Service #11</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                    <li>
                                                        <a class="cd-dropdown-item item-12" href="#">
                                                            <h3>Service #12</h3>
                                                            <p>This is the item description</p>
                                                        </a>
                                                    </li>

                                                </ul> <!-- .cd-dropdown-icons -->
                                            </li> <!-- .has-children -->

                                            <li class="cd-divider">Divider</li>

                                            <li><a href="#">Page 1</a></li>
                                            <li><a href="#">Page 2</a></li>
                                            <li><a href="#">Page 3</a></li>
                                        </ul> <!-- .cd-dropdown-content -->
                                    </nav> <!-- .cd-dropdown -->
                                </div> <!-- .cd-dropdown-wrapper -->
                      </div><!--end of tokoinput-->
                </div>
                <div class="col s12 cards-container">
                    
                </div>
            </div><!--end of row1-->
            <div class="row">
                    <div class="sidebar filters">
                      <div class="block">
                        <h3 class="title">TYPE</h3>
                        <ul>
                          <li><a href="#" class="checked">Lorem del Ces</a></li>
                          <li><a href="#">Ispum ce Peupil</a></li>
                          <li><a href="#">Lorem del Ces</a></li>
                          <li><a href="#">Ispum ce Peupil</a></li>
                        </ul>
                      </div>
                      <div class="block">
                        <h3 class="title">Color</h3>
                        <ul>
                          <li><a href="#">Blue</a></li>
                          <li><a href="#" class="checked">Charcoal</a></li>
                          <li><a href="#">Green</a></li>
                          <li><a href="#">Red</a></li>
                        </ul>
                      </div>
                      <div class="block">
                        <h3 class="title">Size</h3>
                        <ul>
                          <li><a href="#">Petite</a></li>
                          <li><a href="#" class="checked">Medium</a></li>
                          <li><a href="#">Large</a></li>
                        </ul>
                      </div>
                    </div>
                    <!--  end .sidebar.filters  -->
                    <div class="product-grid">
                      
                      <div class="item-render">
                        <div class="item item-template">
                          <a href="#">
                            <div class="product-image">
                              <img  height="300px" src="src/img/someimg.png" class="img-responsive" />
                            </div>
                            <div class="hidden actions">
                              <a href="#" class="quick-view" title="View Quick Details"><i class="fa fa-search"></i></a>
                            </div>
                            <div class="details">
                              <p class="kode">Product Code</p>
                                <p class="name">Product Name</p>
                              <p class="price">Rp10.000,-</p>
                                <button>Buy this</button>
                            </div>
                          </a>
                        </div>
                      </div>
                      <!-- end .item -->
                      <div class="render"></div>
                    </div>
                    <!-- end .product-grid -->

                <div class="col s12 cards-container">
                    
                </div>
            </div><!--end of row2-->
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