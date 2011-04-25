package {
	import flash.filters.GlowFilter;
	import flash.filters.DropShadowFilter;
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.text.*;

	public class Buttons {


		public static function createButton() {
			var radius:Number = 24;
			var btnW = 200;
			var btnH = 70;
			var web20Glow:GlowFilter = new GlowFilter(0xF7A95C, 100, 6, 6, 3, 3, true, false);
			var web20Filters:Array = [web20Glow];
			var myRssButton:MovieClip = new MovieClip();
			var fillType = GradientType.LINEAR;
			var colors:Array = [0xF69C46, 0xEF5A2B];
			var alphas:Array = [100, 100];
			var ratios:Array = [0, 245];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(btnW, btnH, 90/180*Math.PI, 0, 0);
			var buttonBkg:MovieClip = new MovieClip();
			myRssButton.addChild(buttonBkg);
			with (buttonBkg.graphics) {
				lineStyle(0, 0xE88A41, 100, true, "none", "square", "round");
				beginGradientFill(fillType, colors, alphas, ratios, matrix);
				moveTo(radius, 0);
				lineTo((btnW-radius), 0);
				curveTo(btnW, 0, btnW, radius);
				lineTo(btnW, (btnH-radius));
				curveTo(btnW, btnH, (btnW-radius), btnH);
				lineTo(radius, btnH);
				curveTo(0, btnH, 0, (btnH-radius));
				lineTo(0, radius);
				curveTo(0, 0, radius, 0);
				endFill();
			}
			var shineRadius:Number = 16;
			var shineW = 184;
			var shineH = 32;
			var shineFillType = GradientType.LINEAR;
			var shineColors:Array = [0xFFFFFF, 0xFFFFFF];
			var shineAlphas:Array = [0.7, 0];
			var shineRatios:Array = [0, 255];
			var shineMatrix:Matrix = new Matrix();
			shineMatrix.createGradientBox(shineW, shineH, 90/180*Math.PI, 0, 0);
			var shine:MovieClip = new MovieClip();
			myRssButton.addChild(shine);
			shine.x = 8;
			shine.y = 3;
			with (shine.graphics) {
				lineStyle(0, 0xFFFFFF, 0);
				beginGradientFill(shineFillType, shineColors, shineAlphas, shineRatios, shineMatrix);
				moveTo(shineRadius, 0);
				lineTo((shineW-shineRadius), 0);
				curveTo(shineW, 0, shineW, shineRadius);
				lineTo(shineW, (shineH-shineRadius));
				curveTo(shineW, shineH, (shineW-shineRadius), shineH);
				lineTo(shineRadius, shineH);
				curveTo(0, shineH, 0, (shineH-shineRadius));
				lineTo(0, shineRadius);
				curveTo(0, 0, shineRadius, 0);
				endFill();
			}
			var myRssFormat:TextFormat = new TextFormat();
			myRssFormat.align = "left";
			myRssFormat.font = "Arial";
			myRssFormat.size = 18;
			myRssFormat.bold = false;
			myRssFormat.color = 0xFFFFFF;
						
			var labelText:TextField = new TextField();
			labelText.x = 70;
			labelText.y = 26;
			labelText.width = 120;
			labelText.height = 30;
			labelText.text = "RSS Feeds";
			labelText.selectable = false;
			labelText.antiAliasType = flash.text.AntiAliasType.ADVANCED;
			labelText.setTextFormat(myRssFormat);

			var labelGlow:GlowFilter = new GlowFilter(0xFFFFFF, .90, 4, 4, 3, 3, false, true);
			var labelFilters:Array = [labelGlow];
			labelText.filters = labelFilters;

			myRssButton.addChild(labelText);

			buttonBkg.filters = web20Filters;

			var ic:MovieClip = new MovieClip();
			myRssButton.addChild(ic);
			ic.x=30;
			ic.y=23;
			with (ic.graphics) {
				lineStyle(5, 0xFFFFFF, 100, true, "normal", "none");
				curveTo(26, 0, 26, 26);
				moveTo(0, 9)
				curveTo(17, 9, 17, 26);
				moveTo(5, 21)
				lineStyle(7, 0xFFFFFF, 100, true, "normal", "round");
				lineTo(4, 21);
			}
			var icGlow:GlowFilter = new GlowFilter(0xFFFFFF, .30, 4, 4, 3, 3);
			var icFilters:Array = [icGlow];
			ic.filters = icFilters;

			return myRssButton;
		}


	}


}

