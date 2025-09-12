// Sidebar colapsable con Bootstrap grid + persistencia (localStorage).
// Importante: registramos SOLO en "turbo:load" y evitamos listeners duplicados.
document.addEventListener("turbo:load", initSidebarToggle);

function initSidebarToggle() {
    const sidebar = document.getElementById("sidebar");
    const main = document.getElementById("content-col");
    const btn = document.getElementById("sidebarToggleBtn");
    const icon = document.getElementById("sidebarToggleIcon");

    if (!sidebar || !btn) return;

    // Evita registrar el click más de una vez (Turbo puede disparar múltiples loads)
    if (btn.dataset.bound === "1") return;
    btn.dataset.bound = "1";

    //const STORAGE_KEY = "ui:sidebar:collapsed";
    //const saved = localStorage.getItem(STORAGE_KEY) === "true";
    //applyState({ sidebar, main, icon, collapsed: saved });

    const STORAGE_KEY = "ui:sidebar:collapsed";
    // Si no hay preferencia guardada, por defecto: COLAPSADO
    const stored = localStorage.getItem(STORAGE_KEY);
    const initialCollapsed = (stored === null) ? true : (stored === "true");

    applyState({ sidebar, main, icon, collapsed: initialCollapsed });

    // si era la primera vez (sin preferencia), la dejamos grabada en true
    if (stored === null) localStorage.setItem(STORAGE_KEY, "true");

    btn.addEventListener("click", (e) => {
        e.preventDefault();
        const nowCollapsed = !sidebar.classList.contains("is-collapsed");
        applyState({ sidebar, main, icon, collapsed: nowCollapsed });
        localStorage.setItem(STORAGE_KEY, String(nowCollapsed));
    });
}

function applyState({ sidebar, main, icon, collapsed }) {
    // 1) Flag visual para ocultar textos
    sidebar.classList.toggle("is-collapsed", collapsed);

    // 2) Ajuste de columnas Bootstrap (tu layout usa col-lg/xl) 
    if (!main) return;

    if (collapsed) {
        swapCols(sidebar, ["col-lg-3", "col-xl-2"], ["col-lg-1", "col-xl-1"]);
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
    removeList.forEach(c => el.classList.remove(c));
    addList.forEach(c => el.classList.add(c));
}

function swapIcon(icon, dir) {
    if (!icon) return;
    icon.classList.remove("fa-chevron-left", "fa-chevron-right");
    icon.classList.add(dir === "left" ? "fa-chevron-left" : "fa-chevron-right");
}
