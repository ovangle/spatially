part of geomgraph._base;

abstract class GraphComponent {
  Label _label;
  
  /**
   * Has this component already been included in the result?
   */
  bool _isInResult;
  bool _isCovered;
  bool _isCoveredSet;
  bool _isVisited;
  
  GraphComponent(Label this._label) :
    _isInResult = false,
    _isCovered = false,
    _isCoveredSet = false,
    _isVisited = false;
  
  bool get isInResult => _isInResult;
  bool get isCovered => _isCovered;
  bool get isCoveredSet => _isCoveredSet;
  bool get isVisited => _isVisited;
  
  /**
   * A coordinate in this component (if there is one, otherwise `null`)
   */
  Coordinate get coordinate;
  
  /**
   * Return the [IntersectionMatrix] computed for this component
   */
  IntersectionMatrix get _computedIntersectionMatrix;
  
  /**
   * An isolated component does not intersect or touch
   * any other component.
   */
  bool get isIsolated;
  
  /**
   * Updates the [IntersectionMatrix] with the contribution
   * from `this`. A labelling is required for both parent geometries
   * in order to be included in the contribution.
   */
  IntersectionMatrix updateIntersectionMatrix(IntersectionMatrix m);
}