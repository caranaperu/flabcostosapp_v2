<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Future Labs - Costos</title>
<body>

</body>
<script>
    var f = document.createElement('form');
    f.action='../application/client/systemEntry.php';
    f.method='POST';

    var i=document.createElement('input');
    i.type='hidden';
    i.name='usuario_name';
    i.value='<?php echo $this->session->userdata("usuario_name") ?>';
    f.appendChild(i);


    var g=document.createElement('input');

    g.type='hidden';
    g.name='curDate';
    g.value='<?php echo date('d-m-Y') ?>';
    f.appendChild(g);


    document.body.appendChild(f);
    f.submit();
    </script>
</html>