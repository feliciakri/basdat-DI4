<?php
session_start();
include('dbconnect.php');
$conn = connectDB();
?>

<?php
$result1 = pg_query($conn, "SET SEARCH_PATH TO TOKOKEREN;
SELECT nama
FROM toko;");
echo "<script>console.log(".($result1).")</script>";
if (!$result1) {
  echo "An error occurred.\n";
  exit;
}

?>
<select style="width:500px" id="input_toko" name="pilihtoko">
           <?php
                  while ($row = pg_fetch_array($result1)){
                   echo '<option value="'.$row['nama'].'">'.$row['nama'].'</option>';
                   }

?>
 </select>
<br>

<?php

$result = pg_query($conn, "SET SEARCH_PATH TO TOKOKEREN;
SELECT kategori_utama.kode, kategori_utama.nama, sub_kategori.kode, sub_kategori.nama
FROM sub_kategori
INNER JOIN kategori_utama ON kategori_utama.kode = sub_kategori.kode_kategori;");
if (!$result) {
  echo "An error occurred.\n";
  exit;
}

$myarray = array();
while ($row = pg_fetch_row($result)) {
  $myarray[] = $row;
}
$dbarr = $myarray;

//Indentify the fields from the output array - so that we can create a well-formed arrays
$keys = array('kategoriutama'=>array(0,1),'subkategori'=>array(2,3));

//This just gives some hooks for javascript and the select dropdown 'id' properties
$json_keys = json_encode(array_keys($keys));

//Create the arrays
function makeArrays($data,$keys){
 foreach($data as $record){
  $pos = 0;
  foreach($keys as $k=>$v){
   if($pos == 0){
    $r[$k][$record[$v[0]]] = $record[$v[1]];

   }else{
    $r[$k][$prev][$record[$v[0]]] = $record[$v[1]];
   }
   $prev = $record[$v[0]];
   $pos++;
  }
 }
 return $r;
}

//encode the data for use in javascript
$json = json_encode(makeArrays($dbarr,$keys));
?>
<select id="kategoriutama" class="linkedselects"></select>
<select id="subkategori" class="linkedselects"></select>

<script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
<script>
   //store data in json format from php
   var json = <?php echo $json;?>;
   var controls = <?php echo $json_keys;?>;

   //run on page load
   initiateSelects();

   //start creating select (cascade)
   function initiateSelects(selectId){
      if(selectId != null){
         start = controls.indexOf(selectId) + 1;
      }else{
         start = 0;
      }
      $.each(controls, function(i,v){
         if(i >= start){
            if(i == 0){
               $('#' + controls[i]).html(makeOptions(controls[i]));
            }else{
               id = $('#' + controls[i-1]).val();
               $('#' + controls[i]).html(makeOptions(controls[i], id));
            }
         }
      });
   }

   //change selection in country dropdown
   $('.linkedselects').change(function(){
       selectId = $(this).attr('id');
       initiateSelects(selectId);
   });

   //create options for selects
   function makeOptions(level, id){
      output = '';
      if(id == null){
         arr = json[level];
      }else{
         arr = json[level][id];
      }
      $.each(arr, function(i,v){
         output += '<option value="' + i + '">' + v + '</option>';
      });
         return output;
   }
</script>
