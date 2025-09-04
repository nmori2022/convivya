import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() { this.enter() }
    enter() {
        this.element.classList.add("fade-enter")
        requestAnimationFrame(() => {
            this.element.classList.add("fade-enter-active")
            this.element.addEventListener("transitionend", () => {
                this.element.classList.remove("fade-enter", "fade-enter-active")
            }, { once: true })
        })
    }
}
