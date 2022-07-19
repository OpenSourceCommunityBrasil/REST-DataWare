<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="https://getbootstrap.com/favicon.ico">

    <title>Consumindo servidor RestDataware</title>

    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/dashboard.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-dark sticky-top bg-dark flex-md-nowrap p-0">
        <a class="navbar-brand col-sm-3 col-md-2 mr-0" href="index.html">
            <img src="imgs/logodw.png" alt="RestDataware" title="RestDataware"/>
        </a>
        <h4 class="white margLeft">Consumindo um servidor Rest Dataware com PHP</h4>
    </nav>

    <main role="main" class="col-md-9 ml-sm-auto col-lg-12 pt-3 px-4">
        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-pessoas-center pb-2 mb-3 border-bottom">
            <h5 class="">Listagem de Trabalhadores</h5>
        </div>

        <div class="table-responsive">
            <table class="table table-striped table-sm">
                <thead>
                    <tr class="bgTR">
                        <th class="text-center"><a href="#">Emp. No<</a></th>
                        <th class="text-center"><a href="#">First Name</a></th>
                        <th><a href="#">Last Name</a></th>
                        <th><a href="#">Hire Date</a></th>
                        <th class="text-center"><a href="#">Job Country</a></th>
                        <th class="text-center"><a href="#">Salary</a></th>
                        <th class="text-center"><a href="#">Full Name</a></th>
                    </tr>
                </thead>
                <tbody>

                    <?php
                    $valor_id = 0;
                    /*
					if (isset($_REQUEST['a'])) {
                        $a = $_REQUEST['a'];
                        if ($a == "buscar") {
                            if(is_numeric(trim($_REQUEST['valor_id']))) {
                                $valor_id = trim($_REQUEST['valor_id']);
                            } else {
                                if (!empty(trim($_REQUEST['valor_id']))) {
                                    echo "<div class=\"erro\"><p>Somente numeros para pesquisa ou 0 para listar todos os registros.</p></div>";
                                }
                            }
                        }
                    }
*/
                    $url = "http://testserver:testserver@localhost:8082/getemployee"; //<!-- &dwwelcomemessage=&accesstag=cmVzdGR3";-->
                    $json = file_get_contents($url);
                    if ($json) {
                        $json_output = json_decode($json);

                        //MUDAR QUANDO FOR UM OBJ JSON ou ARRAY JSON
                        $dadosArray = $json_output;
//						var_dump($dadosArray);

                        if (is_array($dadosArray)) {
                            if (!empty($dadosArray)) {
                                $qtd        = 50;
                                $atual      = (isset($_GET['pg'])) ? intval($_GET['pg']) : 1;
                                $pagArquivo = array_chunk($dadosArray, $qtd);
                                $contar     = count($pagArquivo);
                                $resultado  = $pagArquivo[$atual-1];

                                foreach ( $resultado as $valor ) {
                                    echo "<tr>";
                                    echo "<td class=\"text-center\">$valor->EMP_NO</td>";
                                    echo "<td class=\"text-center\">$valor->FIRST_NAME</td>";
                                    echo "<td>$valor->LAST_NAME</td>";
                                    echo "<td>$valor->HIRE_DATE</td>";
                                    echo "<td class=\"text-center\">$valor->JOB_COUNTRY</td>";
                                    echo "<td class=\"text-center\">$valor->SALARY</td>";
                                    echo "<td class=\"text-center\">$valor->FULL_NAME</td>";
                                    echo "</tr>";
                                }

                                for ($i = 1; $i < $contar; $i++) {
                                    if ($i == $atual) {
                                        echo("<a href=\"#\" class=\"bg-info text-white\">( $i )</a>");
                                    } else {
                                        echo("<a href=\"?pg=$i\" class=\"text-secondary\"> $i </a>");
                                    }
                                }
                            }
                        } else {
                            echo "<div class=\"erro\"><p>Nenhum registro encontrado.</p></div>";
                        }
                    }
                    ?>

                </tbody>
            </table>
        </div>
    </main>
    <script src="js/feather.min.js"></script>
    <script> feather.replace() </script>
</body>
</html>
