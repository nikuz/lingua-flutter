double remapValue({
  required double value,
  required double inMin,
  required double inMax,
  required double outMin,
  required double outMax,
}) {
  if (value < inMin) {
    return outMin;
  } else if (value > inMax) {
    return outMax;
  }

  return (((value - inMin) * (outMax - outMin)) / (inMax - inMin)) + outMin;
}