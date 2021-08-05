
class InputInfo {
  bool  _isIndividual;
  int   _amount;

  InputInfo(bool isIndividual, int amount) {
    _isIndividual = isIndividual;
    _amount = amount;
  }

  int getAmount() {
    return _amount;
  }

  bool getIsIndividual() {
    return _isIndividual;
  }

  void setAmount(int amount) {
    _amount = amount;
  }

  void setIsIndividual(bool isIndividual) {
    _isIndividual = isIndividual;
  }

  void toggleIndividual() {
    _isIndividual = !_isIndividual;
  }
}

