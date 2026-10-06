/// Simulated backend conditions for the Fake* repositories, so every screen's
/// four required states (loading, empty, error, no backend) can be reviewed.
enum DemoScenario {
  normal('Normal'),
  loading('Cargando'),
  empty('Vacío'),
  error('Error'),
  offline('Sin backend');

  const DemoScenario(this.label);
  final String label;
}
