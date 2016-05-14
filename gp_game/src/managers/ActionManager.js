// Generated by CoffeeScript 1.10.0

/*
  特效，动画效果管理
 */

(function() {
  this.ActionManager = {
    swapCellsAction: function(point, cbFunc) {
      var moveTo, sequence;
      moveTo = cc.moveTo(0.2, point).easing(cc.easeIn(0.5));
      sequence = cc.sequence(moveTo, ccUtil.callFunc(cbFunc, "swapCells Action "));
      return sequence;
    },
    selectCellAction: function() {
      var blink, delay, fadeOut, fadeOutBack, sequence;
      blink = cc.blink(10, 20).repeatForever();
      delay = cc.delayTime(1.0);
      fadeOut = cc.fadeOut(2.0);
      fadeOutBack = fadeOut.reverse();
      sequence = cc.sequence(delay, fadeOut, fadeOutBack).repeatForever();
      return sequence;
    },
    turnCellAction: function(color, cbFunc) {
      var blink, sequence, spawn, tintAction, whiteTint;
      whiteTint = cc.tintTo(0.5, 255, 255, 255);
      tintAction = cc.tintTo(0.5, color.r, color.g, color.b);
      blink = cc.blink(2, 5);
      spawn = cc.spawn(blink, cc.rotateBy(2, 720));
      sequence = cc.sequence(whiteTint, tintAction, ccUtil.callFunc(cbFunc, "turnCellAction "));
      return sequence;
    },
    shaderOutlineShine: function(sprite) {
      var glProgram_state, shader;
      if (cc.sys.capabilities.opengl) {
        if (cc.sys.isNative) {
          shader = new cc.GLProgram(resImg.outline_noMVP, resImg.outline_fsh);
          shader.link();
          shader.updateUniforms();
        } else {
          shader = new cc.GLProgram(resImg.outline_vsh, resImg.outline_fsh);
          shader.addAttribute(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION);
          shader.addAttribute(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS);
          shader.addAttribute(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR);
          shader.link();
          shader.updateUniforms();
          shader.use();
          shader.setUniformLocationWith1f(shader.getUniformLocationForName('u_threshold'), 11.75);
          shader.setUniformLocationWith3f(shader.getUniformLocationForName('u_outlineColor'), 0 / 255, 255 / 255, 0 / 255);
        }
        if (cc.sys.isNative) {
          glProgram_state = cc.GLProgramState.getOrCreateWithGLProgram(shader);
          glProgram_state.setUniformFloat("u_threshold", 11.75);
          glProgram_state.setUniformVec3("u_outlineColor", {
            x: 0 / 255,
            y: 255 / 255,
            z: 0 / 255
          });
          sprite.setGLProgramState(glProgram_state);
        } else {
          sprite.shaderProgram = shader;
        }
        jlog.cc(shader);
        return shader;
      }
    },
    removeOutlineShine: function(sprite) {
      var glProgram_state;
      if (cc.sys.isNative) {
        return glProgram_state = sprite.getGLProgramState();
      } else {

      }
    },
    rotateAction: function() {
      var begin, delay, finish, rotateToLeft, rotateToOrigin, rotateToRight, sequence;
      rotateToLeft = cc.rotateTo(0.2, 45);
      rotateToRight = cc.rotateTo(0.2, -45);
      rotateToOrigin = cc.rotateTo(0.2, 0);
      delay = cc.delayTime(0.25);
      begin = function() {
        return AudioManager.playLoadingFinish();
      };
      finish = function() {
        return AudioManager.stopLoadingFinish();
      };
      sequence = cc.sequence(ccUtil.callFunc(begin), rotateToLeft, rotateToOrigin, rotateToRight, rotateToOrigin, ccUtil.callFunc(finish)).repeatForever();
      return sequence;
    },
    cardShake: function() {
      var delay, rotateToLeft, rotateToOrigin, rotateToRight, sequence;
      rotateToLeft = cc.rotateTo(0.2, 10);
      rotateToRight = cc.rotateTo(0.2, -10);
      rotateToOrigin = cc.rotateTo(0.1, 0);
      delay = cc.delayTime(2.0);
      sequence = cc.sequence(rotateToLeft, rotateToRight, rotateToOrigin, delay).repeatForever();
      return sequence;
    }
  };

}).call(this);

//# sourceMappingURL=ActionManager.js.map