<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>CLABS</title>
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

    var l=document.createElement('input');
    l.type='hidden';
    l.name='empresa_id';
    l.value='<?php echo $this->session->userdata("empresa_id") ?>';
    f.appendChild(l);


    var g=document.createElement('input');

    g.type='hidden';
    g.name='curDate';
    g.value='<?php echo date('d-m-Y') ?>';
    f.appendChild(g);


    document.body.appendChild(f);
    f.submit();
    </script>
</html>