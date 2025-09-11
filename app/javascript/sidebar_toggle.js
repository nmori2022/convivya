// Sidebar toggle con soporte para Bootstrap grid.
// - Aplica/remueve "is-collapsed" (para ocultar textos)
// - Cambia clases de grid en <aside id="sidebar"> y <main id="content-col">
// - Persiste estado en localStorage
document.addEventListener("turbo:load", initSidebarToggle);
document.addEventListener("DOMContentLoaded", initSidebarToggle);

function initSidebarToggle() {
    const sidebar = document.getElementById("sidebar");
    const main = document.getElementById("content-col");
    const btn = document.getElementById("sidebarToggleBtn");
    const icon = document.getElementById("sidebarToggleIcon");
    if (!sidebar || !btn) return;

    const STORAGE_KEY = "ui:sidebar:collapsed";

    // Estado guardado
    const saved = localStorage.getItem(STORAGE_KEY) === "true";
    applyState({ sidebar, main, icon, collapsed: saved });

    btn.addEventListener("click", () => {
        const nowCollapsed = !sidebar.classList.contains("is-collapsed");
        applyState({ sidebar, main, icon, collapsed: nowCollapsed });
        localStorage.setItem(STORAGE_KEY, String(nowCollapsed));
    });
}

function applyState({ sidebar, main, icon, collapsed }) {
    // 1) Flag visual para ocultar textos
    sidebar.classList.toggle("is-collapsed", collapsed);

    // 2) Ajuste de columnas Bootstrap SOLO si el usuario está logueado
    //    (tu layout usa col-lg-9/10 cuando user_signed_in?)
    if (!main) return;

    if (collapsed) {
        // aside:  col-lg-3 col-xl-2  ->  col-lg-1 col-xl-1
        swapCols(sidebar, ["col-lg-3", "col-xl-2"], ["col-lg-1", "col-xl-1"]);
        // main:   col-lg-9 col-xl-10 ->  col-lg-11 col-xl-11
        swapCols(main, ["col-lg-9", "col-xl-10"], ["col-lg-11", "col-xl-11"]);
        swapIcon(icon, "right");
        sidebar.setAttribute("aria-expanded", "false");
    } else {
        swapCols(sidebar, ["col-lg-1", "col-xl-1"], ["col-lg-3", "col-xl-2"]);
        swapCols(main, ["col-lg-11", "col-xl-11"], ["col-lg-9", "col-xl-10"]);
        swapIcon(icon, "left");
        sidebar.setAttribute("aria-expanded", "true");
    }
}

function swapCols(el, removeList, addList) {
    if (!el) return;
    removeList.forEach(c => el.classList.remove(c));
    addList.forEach(c => el.classList.add(c));
}

function swapIcon(icon, dir) {
    if (!icon) return;
    icon.classList.remove("fa-chevron-left", "fa-chevron-right");
    icon.classList.add(dir === "left" ? "fa-chevron-left" : "fa-chevron-right");
}
