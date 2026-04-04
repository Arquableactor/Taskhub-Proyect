/* ========================= */
/* CONFIG */
/* ========================= */

const API_URL = "http://localhost:5176/tasks";

/* ========================= */
/* DOM */
/* ========================= */

const form = document.getElementById("formulario");
const input = document.getElementById("tareaInput");
const lista = document.getElementById("lista");
const contador = document.getElementById("contador");
const error = document.getElementById("error");

const btnTodos = document.getElementById("filtroTodos");
const btnPendientes = document.getElementById("filtroPendientes");
const btnCompletadas = document.getElementById("filtroCompletadas");
const btnLimpiar = document.getElementById("limpiarCompletadas");

/* ========================= */
/* ESTADO */
/* ========================= */

let tareas = [];
let filtro = "todos";

/* ========================= */
/* API */
/* ========================= */

async function obtenerTareas() {
    try {
        const res = await fetch(API_URL);
        if (!res.ok) throw new Error("Error al cargar tareas");
        return await res.json();
    } catch (err) {
        error.textContent = err.message;
        return [];
    }
}

async function crearTarea(texto) {
    try {
        const res = await fetch(API_URL, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                texto,
                completada: false
            })
        });

        if (!res.ok) throw new Error("Error al crear tarea");

    } catch (err) {
        error.textContent = err.message;
    }
}

async function actualizarTarea(tarea) {
    try {
        const res = await fetch(`${API_URL}/${tarea.id}`, {
            method: "PATCH",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(tarea)
        });

        if (!res.ok) throw new Error("Error al actualizar tarea");

    } catch (err) {
        error.textContent = err.message;
    }
}

async function eliminarTarea(id) {
    try {
        const res = await fetch(`${API_URL}/${id}`, {
            method: "DELETE"
        });

        if (!res.ok) throw new Error("Error al eliminar tarea");

    } catch (err) {
        error.textContent = err.message;
    }
}

/* ========================= */
/* LÓGICA */
/* ========================= */

function obtenerFiltradas() {
    if (filtro === "pendientes") {
        return tareas.filter(t => !t.completada);
    }

    if (filtro === "completadas") {
        return tareas.filter(t => t.completada);
    }

    return tareas;
}

function actualizarContador() {
    contador.textContent = tareas.filter(t => !t.completada).length;
}

/* ========================= */
/* RENDER */
/* ========================= */

function render() {
    lista.innerHTML = "";

    const visibles = obtenerFiltradas();

    visibles.forEach(tarea => {
        lista.appendChild(crearElemento(tarea));
    });

    actualizarContador();
}

function crearElemento(tarea) {
    const li = document.createElement("li");

    if (tarea.completada) {
        li.classList.add("completada");
    }

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.checked = tarea.completada;

    checkbox.addEventListener("change", async () => {
        tarea.completada = checkbox.checked;
        await actualizarTarea(tarea);
        cargarTareas();
    });

    const span = document.createElement("span");
    span.textContent = tarea.texto;

    span.addEventListener("dblclick", async () => {
        const nuevo = prompt("Editar tarea:", tarea.texto);

        if (nuevo && nuevo.trim() !== "") {
            tarea.texto = nuevo.trim();
            await actualizarTarea(tarea);
            cargarTareas();
        }
    });

    const btnEliminar = document.createElement("button");
    btnEliminar.textContent = "X";

    btnEliminar.addEventListener("click", async () => {
        await eliminarTarea(tarea.id);
        cargarTareas();
    });

    li.appendChild(checkbox);
    li.appendChild(span);
    li.appendChild(btnEliminar);

    return li;
}

/* ========================= */
/* EVENTOS */
/* ========================= */

form.addEventListener("submit", async e => {
    e.preventDefault();

    const texto = input.value.trim();

    if (!texto) {
        error.textContent = "No puedes agregar una tarea vacía";
        return;
    }

    const btn = form.querySelector("button");
    btn.disabled = true;

    await crearTarea(texto);

    btn.disabled = false;

    input.value = "";
    cargarTareas();
});

btnTodos.onclick = () => {
    filtro = "todos";
    render();
};

btnPendientes.onclick = () => {
    filtro = "pendientes";
    render();
};

btnCompletadas.onclick = () => {
    filtro = "completadas";
    render();
};

btnLimpiar.onclick = async () => {
    const completadas = tareas.filter(t => t.completada);

    for (const tarea of completadas) {
        await eliminarTarea(tarea.id);
    }

    cargarTareas();
};

input.addEventListener("input", () => {
    error.textContent = "";
});

/* ========================= */
/* INIT */
/* ========================= */

async function cargarTareas() {
    tareas = await obtenerTareas();
    render();
}

cargarTareas();