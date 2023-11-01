/**
 * Balanced filament spool holder, rotated 90º, making
 * rotation axis parallel to the gantry, and centre of
 * the mass right in the middle of it. It zeroes out
 * all possible torques caused by filament weight,
 * resultin to more consistent printing.
 *
 * Inspired by this model (although not a remix):
 * https://www.printables.com/model/572862-ender-3-v3-se-spool-holder
 *
 * © David Avsajanishvili <david@davidavs.com> 2023
 */

// Width of the top gantry (mm)
gantryWidth = 29.5;

// Width of the original spool holder (mm)
holderWidth = 43.5;

// Width of the back bottom part of the original holder (the one with holes) (mm)
holderBackBottomWidth = 21;

// Thickness of the material from which the original spool holder is made (mm)
holderMaterialThickness = 1.6;

// Diameter of the fixation holes on the original spool holder (mm)
holderScrewHolesDiameter = 5;

// Distance between the fixation holes on the original spool holder (mm)
holderScrewHolesDistance = 20;

// Diameter of the screw head (mm)
holderScrewHeadDiameter = 9.2;

// Width of each of the 3 vertical holes on the original spool holder (mm)
holderVerticalMiddleHoleWidth = 5.85;
holderVerticalSideHolesWidth = 6.00;

// Length of each of the 3 vertical holes on the original spool holder (mm)
holderVerticalHolesLength = 80.50;

// Height of each of the 3 vertical holes from the surface of the gantry (mm)
holderVerticalHolesHeight = 17;

// Distance between the 3 vertical holes (mm)
holderVerticalHolesDistance = 6.2;
holderVerticalHolesMiddleDistance = holderVerticalHolesDistance + (
    holderVerticalMiddleHoleWidth + holderVerticalSideHolesWidth
) / 2;

// Length of the active part of the holder roller (mm)
holderRollerLength = 98;

// Thickness of all parts of the new holder frame (mm)
frameThickness = 5;

// Length of the vertical cathetus of enforcing triangles (mm)
enforcingTriangleVerticalLength = 15;

// Length of the horizontal cathetus of enforcing triangle (mm)
enforcingTriangleHorizontalLength = 30;

// Width of the enforcing triangle base (mm)
enforcingTriangleBaseWidth = 15;

// Depth of the extension that goes to the middle vertical hole (mm)
extensionDepth = 5;

// Height of the back stop (mm)
bottomStopHeight = 1.6;

// Thickness of the part where screw goes (mm)
screwHoleThickness = 1.6;

// Length of the pins to go into the original holder holes
pinLength = 6;

// Allowance for fitting (mm, from ech side!)
allowance = 0.2;


bottomLength = holderRollerLength + (frameThickness + holderBackBottomWidth + 2 * allowance) * 2;
onlyPins = false;
withPins = false;

module bottomHole()
    translate([0, bottomLength / 2, holderWidth / 2])
        rotate([0, 90, 0])
            union() {
                linear_extrude(frameThickness * 5)
                    circle(holderScrewHolesDiameter / 2, $fn=50);
                translate([0, 0, frameThickness + screwHoleThickness]) linear_extrude(frameThickness * 5)
                    circle(holderScrewHeadDiameter / 2 + allowance, $fn=50);
            };
module bottomPart() difference() {
    union() {
        translate([-frameThickness, 0, 0]) linear_extrude(holderWidth)
            square([frameThickness, bottomLength]);
    };
    union() {
        translate([-frameThickness * 2, -holderScrewHolesDistance / 2, 0]) bottomHole();
        translate([-frameThickness * 2, +holderScrewHolesDistance / 2, 0]) bottomHole();
    }
};

module backPart() linear_extrude(holderWidth)
    polygon([
        [0, 0],
        [0, frameThickness + holderBackBottomWidth - holderMaterialThickness],
        [allowance * 2, frameThickness],
        [bottomStopHeight, frameThickness + allowance],
        [bottomStopHeight, 0]
    ]);


module extension(width, offset) {
    translate([
        holderVerticalHolesHeight + holderVerticalHolesLength / 2,
        frameThickness + holderBackBottomWidth + allowance * 2,
        holderWidth / 2 + offset
    ])
        rotate([90, 0, 0])
            intersection() {
                linear_extrude(extensionDepth, scale=[1, 0.5])
                    hull() {
                        translate([-(holderVerticalHolesLength - width) / 2, 0, 0])
                            circle(width / 2 - allowance, $fn=50);
                        translate([+(holderVerticalHolesLength - width) / 2, 0, 0])
                            circle(width / 2 - allowance, $fn=50);
                    }
                linear_extrude(
                    extensionDepth,
                    scale=[1 - extensionDepth / holderVerticalHolesLength, 1]
                )
                    hull() {
                        translate([-(holderVerticalHolesLength) / 2, 0, 0])
                            square([width / 3, width], center=true);
                        translate([+(holderVerticalHolesLength) / 2, 0, 0])
                            square([width / 3, width], center=true);
                    }
            }
        
};

module sidePart() union() {
    // frame
    translate([0, frameThickness + holderBackBottomWidth + 2 * allowance, 0])
        linear_extrude(holderWidth)
            square([holderVerticalHolesLength + holderVerticalHolesHeight + frameThickness, frameThickness]);

    // extensions
    extension(holderVerticalMiddleHoleWidth, 0);
    extension(holderVerticalSideHolesWidth, holderVerticalHolesMiddleDistance);
    extension(holderVerticalSideHolesWidth, -holderVerticalHolesMiddleDistance);
}

module bottomSide(mirrorIndex)
    translate([-frameThickness, 0, holderWidth / 2])
        mirror([0, 0, mirrorIndex])
            translate([0, 0, -holderWidth / 2])
                rotate([0, -90, 0])
                    linear_extrude(frameThickness / 2, scale=[0.8, 1])
                        square([(holderWidth - gantryWidth) / 2, bottomLength]);

module enforcingTriangle(mirrorIndex)
    translate([0, frameThickness * 2 + holderBackBottomWidth, holderWidth / 2])
        mirror([0, 0, mirrorIndex])
            translate([0, 0, holderWidth / 2])
                rotate([0, 90, 0])
                    linear_extrude(enforcingTriangleVerticalLength, scale=[frameThickness / enforcingTriangleBaseWidth, 0])
                        square([enforcingTriangleBaseWidth, enforcingTriangleHorizontalLength]);

module pins(slots=false) translate([
    0,
    frameThickness + holderBackBottomWidth / 2 + allowance,
    holderWidth / 2,
]) rotate([0, 90, 0])
    for(m = [0, 1]) mirror([m, 0, 0]) translate([holderScrewHolesDistance / 2, 0, -frameThickness - allowance]) {
        if (slots) {
            linear_extrude(frameThickness * 5) circle(holderScrewHolesDiameter / 2 + allowance, $fn=50);
            linear_extrude(frameThickness - screwHoleThickness + allowance) hull() {
                circle(holderScrewHolesDiameter / 2 + allowance, $fn=50);
                translate([-holderScrewHolesDistance / 2, 0, 0])
                    square(holderScrewHolesDiameter + allowance * 2, center=true);
            }
        } else {
            hull() {
                linear_extrude(frameThickness + pinLength) circle(holderScrewHolesDiameter / 3, $fn=50);
                linear_extrude(frameThickness + pinLength - holderScrewHolesDiameter / 3)
                    circle(holderScrewHolesDiameter / 2, $fn=50);
            }
            linear_extrude(frameThickness - screwHoleThickness) hull() {
                circle(holderScrewHolesDiameter / 2, $fn=50);
                translate([-holderScrewHolesDistance / 2, 0, 0])
                    square(holderScrewHolesDiameter, center=true);
            }
        }
    }
    

module holderWithoutPins() {
    bottomPart();
    sidePart();
    enforcingTriangle(0);
    enforcingTriangle(1);
    backPart();
    bottomSide(0);
    bottomSide(1);
};

module holderWithPins() difference() { holderWithoutPins(); pins(slots=true); };

if (onlyPins) {
    rotate([90, 0, 0]) pins();
} else if (withPins) {
    holderWithPins();
} else {
    holderWithoutPins();
}
