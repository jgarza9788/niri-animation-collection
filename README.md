# niri-animation-collection
A collection of animations and shader presets for niri.


## Install

- Move an animation folder into your niri config directory, for example:
`~/.config/niri/animations/<animation-name>`

- Edit your niri configuration to point to the animation (see the niri wiki for details):

* Example
```
include animations/<animation-name>.kdl
```

## Contribute

Thank you for contributing! Steps:

1. Fork this repository and create a branch.
2. copy `template/template.kdl` to `animations/`, rename it and modify it.
3. Add a gif to `demos/` folder.
4. Run `./update_showcase.sh`
5. Open a pull request with a short description and a screenshot or GIF.

### Guidelines:
- Keep each animation self-contained in its folder.
- Include any metadata or example config needed for niri to load the animation.
- Provide attribution for any third-party assets.


## References

- Configuration reference: https://github.com/niri-wm/niri/wiki/Configuration:-Animations
