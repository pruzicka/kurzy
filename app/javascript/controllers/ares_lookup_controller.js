import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["ico", "name", "street", "city", "zip", "country", "dic", "status"]

  lookup() {
    const ico = this.icoTarget.value.replace(/\s/g, "")
    if (!/^\d{8}$/.test(ico)) return

    this.statusTarget.textContent = "Načítám z ARES..."
    this.statusTarget.classList.remove("hidden", "text-rose-600")
    this.statusTarget.classList.add("text-gray-500")

    fetch(`https://ares.gov.cz/ekonomicke-subjekty-v-be/rest/ekonomicke-subjekty/${ico}`, {
      headers: { "Accept": "application/json" }
    })
      .then(response => {
        if (!response.ok) throw new Error("not_found")
        return response.json()
      })
      .then(data => {
        if (data.kod === "NENALEZENO") throw new Error("not_found")

        if (data.obchodniJmeno) this.nameTarget.value = data.obchodniJmeno
        if (data.dic) this.dicTarget.value = data.dic

        const address = data.sidlo
        if (address) {
          const street = [address.nazevUlice, [address.cisloDomovni, address.cisloOrientacni].filter(Boolean).join("/")].filter(Boolean).join(" ")
          if (street) this.streetTarget.value = street
          if (address.nazevObce) this.cityTarget.value = address.nazevObce
          if (address.psc) this.zipTarget.value = String(address.psc)
          if (address.kodStatu) this.countryTarget.value = address.kodStatu
        }

        this.statusTarget.textContent = "Údaje načteny z ARES"
        this.statusTarget.classList.remove("text-rose-600")
        this.statusTarget.classList.add("text-emerald-600")
        setTimeout(() => this.statusTarget.classList.add("hidden"), 3000)
      })
      .catch(() => {
        this.statusTarget.textContent = "Subjekt nebyl nalezen v ARES"
        this.statusTarget.classList.remove("text-gray-500", "text-emerald-600")
        this.statusTarget.classList.add("text-rose-600")
      })
  }
}
