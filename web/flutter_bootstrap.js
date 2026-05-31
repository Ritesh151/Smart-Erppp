{{flutter_js}}
{{flutter_build_config}}

// Uses HTML renderer to avoid CanvasKit context lost bug
// (LateInitializationError: _handledContextLostEvent)
_flutter.loader.load({
  config: {
    renderer: 'html',
  },
});
