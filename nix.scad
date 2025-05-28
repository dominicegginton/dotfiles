$aperture = 2;
$length = 4;
$clipr = 8;
num = 6;
th = 360 / num / 2;
function tunit() = tan(th)*$unit;
$unit = 25;
$gaps = 1;
colors = ["#5277C3", "#2AA198"];
invclip = false;
show_hexgrid = false;
show_full = true;
pin_l = 4*tunit();
pin_r = 3;
hole_ratio = 1.07;
module regular_polygon(sides, radius)
{
    function dia(r) = sqrt(pow(r*2,2)/2);  //sqrt((r*2^2)/2) if only we had an exponention op
    angles=[ for (i = [0:sides-1]) i*(360/sides) ];
    coords=[ for (th=angles) [radius*cos(th), radius*sin(th)] ];
    polygon(coords);
}

function minsym(x) = (x <= 3 || x % 2 > 0) ? x : minsym(x/2);

module lambda() {
    intersection(){
        union() {
            rotate(-th)
            translate([0,-tunit()*$length])
            square([$unit,$length*tunit()*2], center=true);
            rotate(th)
            square([$unit,tunit()*($length*2 + 2)], center=true);
        }
        square([tunit()*($length + 2), $unit*$length], center=true);
    }
}

module diff(nextangle, debug=false) {
    difference() {
        children();
        rotate(invclip ? nextangle : -nextangle) children();
    }
}

module clipper(){
    intersection() {
        regular_polygon(num, $clipr * tunit());
        children();
    }
}

module placed_lambda() {
    offset(delta = -$gaps)
    clipper()
    diff(360/num)
    translate([tunit() * -$aperture, $unit * -$aperture])
    lambda();
}

module render_logo(segments=[0:num-1]) {
    for (r=segments)
        color(colors[r % len(colors)])
        rotate(th*2*r)
        placed_lambda();
}

module make_pin(scl = 1, r = pin_r) {
    scale([1,scl,scl])
    translate([tunit() * -$aperture, $unit * -$aperture])
    rotate(th)
    translate([0,pin_l/2,0])
    rotate([90,45])
    cube([r * 2, r * 2, pin_l], center=true);
}

module render_module() {
    render()
    difference() {
        union() {
            make_pin(1);
            linear_extrude(printed_h, center=true)

            clipper()
            placed_lambda();
        }
        rotate((invclip ? -1 : 1) * 360/num) make_pin(hole_ratio);
        rotate((invclip ? -2 : 2) * 360/num) make_pin(hole_ratio);
    }
}

difference() {
    render_logo();
};
