document.addEventListener('DOMContentLoaded', function () {
    const url = 'http://localhost:3000/login/ingresar';
    const email = document.getElementById('correo');
    const clave = document.getElementById('clave');
    const btn = document.getElementById('btn');
    const alerta = document.getElementById('alert');


    function ingresar() {
        if (email.value === '' || clave.value === '') {
            alerta.classList.remove('d-none');
            alerta.innerText = 'La contraseña y el email son requeridos';
            return;
        }

        alerta.classList.add('d-none');

        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                email: email.value,
                clave: clave.value
            })
        })
            .then(response => response.json())
            .then(data => validar(data));
    }

    function validar(data) {
        if (data.aceptado) {
            fetch('http://localhost:3000/home/redirect', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    email: email.value,
                    clave: clave.value
                })
            })
                .then(response => response.json())
                .then(data => console.log(data))
                .catch(error => console.log(error))
        } else {
            alerta.classList.remove('d-none');
            alerta.innerText = 'Contraseña o email incorrectos';
        }
    }

    btn.onclick = ingresar;
});