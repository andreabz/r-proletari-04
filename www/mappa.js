const tooltip = document.getElementById("tooltip-provincia");
let provinciaSelezionata = null;

document.querySelectorAll(".province").forEach(provincia => {

  provincia.addEventListener("mousemove", (e) => {
    const nome = provincia.getAttribute("data-nome");
    tooltip.textContent = nome;
    tooltip.style.display = "block";
    tooltip.style.left = (e.pageX + 10) + "px";
    tooltip.style.top = (e.pageY + 10) + "px";

    // Hover: aggiungi classe solo se non selezionata
    if (provincia !== provinciaSelezionata) {
      provincia.classList.add("hover");
    }
  });

  provincia.addEventListener("mouseleave", () => {
    tooltip.style.display = "none";
    provincia.classList.remove("hover");
  });

  provincia.addEventListener("click", () => {
    const sigla = provincia.getAttribute("sigla");
    if (sigla && Shiny) {
      Shiny.setInputValue("provincia_click", sigla, {priority: "event"});
    }

    // Deseleziona tutte le altre province
    document.querySelectorAll(".province").forEach(p => p.classList.remove("selected"));

    // Seleziona la provincia cliccata
    provincia.classList.add("selected");
    provinciaSelezionata = provincia;
  });

});
