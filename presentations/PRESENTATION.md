---
marp: true
class: invert
---

<style>
img[alt~="round"] {
  border-radius: 10px;
}
</style>

<style>
img[alt~="margin"] {
  margin: 30px 30px 30px 30px;
}
</style>

<style>
img[alt~="center"] {
  display: block;
  margin-left: auto;
  margin-right: auto;
}
</style>

![bg](assets/renders/render1_3840x2160_post_processed.png)
# lua-tank-game
*an infinite, wave-based PvE game with tanks. written in LÖVE.*

---

# inspirace
- hra je lehce inspirována hrou 2, 3, 4 player games.

<style>
img[alt~="right"] {
  position: relative;
  left: 420px;
  bottom: 0px;
}
</style>

![width:650 right round margin](assets/234_thumbnail1.png)

---

# procedurální mapa

- barva mapy se mění podle perlin noisu.
- na náhodných místech se generují struktury:
![width:550 round margin](assets/structures.png)

---

# tanky

- všechny tanky mají nějaký počet nábojů a životů...

---

### ...můžou se pohybovat dopředu a dozadu...

![height:500 round margin center](assets/renders/render4_3840x2160_post_processed.png)

---

![height:500 round margin center](assets/renders/render5_3840x2160_post_processed.png)

<h3 style="text-align: right">...otáčet se doprava a doleva...</h3>

---

# <h2 style="text-align: center">...a střílet.</h2>

![height:500 round margin center](assets/renders/render3_3840x2160_post_processed.png)

---

# game loop

![bg](assets/renders/render2_3840x2160_post_processed.png)

- spawnují se vlny nepřátel. po každé vlně se začne další, ve které je o něco víc nepřátel.
<br>
- nepřítelé mají každou vlnu lepší a lepší tanky.
<br>
- když hráč zabije nějakého nepřátele, dostane bonusy ve formě nábojů, životů, atd

---

# nepřátelské AI

- nepřátelské tanky vypočítávají cestu k hráči pomocí **A*** pathfinding algoritmu.
<br>
- pokud hráč není ve viditelnosti, nepřátelský tank se snaží najít nejbližší bod, kde hráč je vidět.
<br>
- když je hráč dostatečně blízko, nepřátelský tank začne střílet.

---

![height:600 center round](assets/astar1.png)

---

<h1 style="text-align: center">demo</h1>

<iframe style="border-radius: 10px; border: none; width: 800px; height: 450px; display: block; margin-left: auto; margin-right: auto" src="http://localhost:8081/video_feed">

</iframe>

---

<h2 style="text-align: center; text-shadow: 0px 0px 1px white;">děkuji za pozornost.</h2>

---

<style>
.container {
  margin: 25px 25px 25px 25px;
  width: 50%;
}
</style>

<div style="width: 100%; height:100%; display: flex; flex-direction: row">
  <div class="container">
    <h1><b>instalace</b></h1>
    - všechen kód i tato prezentace je open-source.
    <br><br>
    - na githubu jsou předkompilované soubory pro Windows, MacOS a Linux.
  </div>

  <div class="container" style="display: flex; flex-direction: column">
    <code style="font-size: 0.92rem">git clone https://github.com/robinafro/lua-tank-game.git</code>
    <img style="border-radius: 10px; margin: 30px" src="assets/api.qrserver.png"/>    
  </div>
</div>