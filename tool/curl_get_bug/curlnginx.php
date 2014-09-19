<?php

//循环截取函数定义开始
function canshujiequ($yuanma,$canshustr,$mubiao){
            if($yuanma=='')return array();
            
            // if(strpos($canshustr,'[data]')==false||strpos($mubiao,'[data1]')==false)
            // {
                // echo 'data或组合字符串格式不对';
                // return array();
            // }
            $chaxunwz=0;
            $canshuarr=array();
            $canshuarr=explode('[data]',$canshustr);
            $len1=count($canshuarr);
            $pipeiarr=array();
            $tpfarr=array();
            $qianks=0;
            $qianjs=0;
            $nowks=0;
            $nowjs=0;
            $end=0;
            $num=0;
            while(($end==0)&&($chaxunwz<strlen($yuanma))){
                    $mubiaofuben=$mubiao;
                    $feikong=0;
                    for($i=0;($end==0)&&($i<$len1);$i++){
                            if($canshuarr[$i]=='')continue;
                            $feikong++;
                            $tpfarr=explode('(*)',$canshuarr[$i]);
                            $len2=count($tpfarr);
                            $feikongnum=0;
                            for($j=0;($j<$len2)&&($end==0);$j++){
                                    if($tpfarr[$j]=='')continue;
                                    $feikongnum++;
                                    if($chaxunwz>=strlen($yuanma)){$end=1;break;}
                                    if(($pipeiwz=strpos($yuanma,$tpfarr[$j],$chaxunwz))!==false){
                                    $chaxunwz=$pipeiwz+strlen($tpfarr[$j]);
                                    if($feikongnum==1)$nowks=$pipeiwz;
                                    $nowjs=$chaxunwz;


                                    }
                                    else{$end=1;break;}
                            }
                            if($end==0){
                                    if($feikong>1){
                                        $str=substr($yuanma,$qianjs,$nowks-$qianjs);
                                        $mubiaofuben=str_replace('[data'.($feikong-1).']',$str,$mubiaofuben);
                                    }
                                    $qianks=$nowks;
                                    $qianjs=$nowjs;
                            }else{
                                break;
                            }
                    }
                    if($end==0){
                        $pipeiarr[]=$mubiaofuben;
                        $num++;
                    }
            }
            return $pipeiarr;
}
//循环截取函数定义结束
function DeleteHtml($str){  
                    $str = trim($str);  
                    $str = ereg_replace("\t","",$str);  
                    $str = ereg_replace("\r\n","",$str);  
                    $str = ereg_replace("\r","",$str);  
                    $str = ereg_replace("\n","",$str);  
                    return trim($str);  
                }  

$ccurl = "http://nginx.org/en/security_advisories.html";
$ch = curl_init();
curl_setopt($ch, CURLOPT_TIMEOUT,5);
curl_setopt($ch, CURLOPT_URL, $ccurl);
// curl_setopt($ch, CURLOPT_HTTPHEADER, array('X-FORWARDED-FOR:8.8.8.8'));
// curl_setopt($ch, CURLOPT_REFERER, "http://sebug.net/appdir/");
curl_setopt($ch, CURLOPT_HEADER, 1);
curl_setopt($ch, CURLOPT_USERAGENT,'Mozilla/5.0 (Windows NT 6.2; WOW64; rv:21.0) Gecko/20100101 Firefox/21.0');
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$yuanma = curl_exec($ch);
curl_close($ch);

$canshustr = '<li><p>[data]</p></li>';  //  截取  http:// 和 /之间的字符
$mubiaostr = '[data1]<br>########################################';   //  把上面找到的字符放到 http://之后进行组合 http://可以随意构造，
$jieguo=canshujiequ($yuanma,$canshustr,$mubiaostr);

// $canshustr2 = 'title="[data]"';
// $mubiaostr2 = '[data1]';
// $canshustr3 = '<li>[data]</li>';
// $mubiaostr3 = '[data1]';
// $jieguo=canshujiequ($yuanma,$canshustr,$mubiaostr);
// $fp=fopen("bug.txt","a");
// $jieguo3=canshujiequ($yuanma,$canshustr3,$mubiaostr3);
// foreach ($jieguo3 as $i => $title)
// {
// $a=canshujiequ($title,$canshustr2,$mubiaostr2);
// $b=canshujiequ($title,$canshustr,$mubiaostr);
// $jieguo2[] = $a[0];
// $jieguo[] = $b[0];
// }
foreach ($jieguo as $i => $r)
{
// $str=$title."\n";
// fwrite($fp,$str);
// if ($r != "")
// echo $r . " Title: " . $jieguo2[$i] . "\n";
//<br\\s*?\/?
$r=preg_replace('/<br>/i',"\n",$r);
$r=preg_replace("'<.*?>'i","",$r);
// $r=mb_convert_encoding($r, "ISO-8859-2", "utf-8");
// $r=preg_replace('/<b>/i',"#",$r);
// $r=preg_replace('/<\/b>/i',"#",$r);
echo $r . "\n";

}
// fclose($fp);
?>

