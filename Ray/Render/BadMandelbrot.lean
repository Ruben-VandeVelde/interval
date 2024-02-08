import Ray.Approx.Box
import Ray.Render.Grid
import Ray.Render.Mandelbrot
import Ray.Render.PNG
import Ray.Render.Potential

/-!
## Bad Mandelbrot images where each pixel corresponds to just one point

This is a warmup: our real images will have each pixel corresponding to an integral
over a square, partitioning the plain.  But these we can draw without the Koebe quarter theorem.
-/

/-- A particular grid around the Mandelbrot set -/
def grid : Grid :=
  .square ⟨-2.1, -1.3⟩ ⟨0.7, 1.3⟩ 2048  -- 256

def main : IO Unit := do
  let f := bad_potential_image (n := 50) (r := 1000)
  let i := Image.ofGrid grid (chunk := 128) f
  let n := (i.find_grid grid (fun _ c ↦ c == nan))[:10]
  IO.print ("nans = " ++ repr n)
  i.write_png "bad-mandelbrot.png"
