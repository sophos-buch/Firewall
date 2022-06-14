#!/usr/bin/perl
# [de] Zweck: viele Firewallregeln fuer SFOS erzeugen
# [en] purpose: generate many firewall rules for SFOS

my $number_of_rules = shift || 10;
my $firewall = "10.5.1.1";
my $username = "admin";
my $password = "dummy";


sub random_ip() {
  return( sprintf "%d.%d.%d.%d",
    1 + int(rand( 222 )), int(rand( 255 )),
    int(rand( 255 )), 1 + int(rand( 254 ))
  );
}


sub api( $ ) {
  my ( $request ) = @_;
  $request =~ s/\n//g;
  $request =~ s/>\s+</></g;

  my $cmd = sprintf "curl --silent -k 'https://$firewall:4444/webconsole/APIController?reqxml=<Request><Login><Username>$username</Username><Password>$password</Password></Login><Set>$request</Set></Request>'";
  #print $cmd . "\n\n";
  system( $cmd . " > /dev/null" );
}


foreach my $c ( 1 .. $number_of_rules ) {
  printf "generating rule #%03d", $c;
  my $port = int( rand( 65535 ));
  my $id   = int( rand( 10**9 ));
  my $time = time();

  api( sprintf(
    "<IPHost>\n".
    "  <Name>source-%09d</Name>\n".
    "  <IPFamily>IPv4</IPFamily>\n".
    "  <HostType>IP</HostType>\n".
    "  <IPAddress>%s</IPAddress>\n".
    "</IPHost>\n",
      $id, random_ip()
  ));
  api( sprintf(
    "<IPHost>\n".
    "  <Name>destination-%09d</Name>\n".
    "  <IPFamily>IPv4</IPFamily>\n".
    "  <HostType>IP</HostType>\n".
    "  <IPAddress>%s</IPAddress>\n".
    "</IPHost>\n",
      $id, random_ip()
  ));


  api( sprintf(
    "<FirewallRule>\n".
    "  <Name>rule-%09d</Name>\n".
    "  <Description>dummy</Description>\n".
    "  <Status>Enable</Status>\n".
    "  <IPFamily>IPv4</IPFamily>\n".
    "  <Position>top</Position>\n".
    "  <PolicyType>Network</PolicyType>\n".
    "  <NetworkPolicy>\n".
    "    <Action>Accept</Action>\n".
    "    <LogTraffic>Disable</LogTraffic>\n".
    "    <SourceZones>\n".
    "      <Zone>WAN</Zone>\n".
    "    </SourceZones>\n".
    "    <SourceNetworks>\n".
    "      <Network>source-%09d</Network>\n".
    "    </SourceNetworks>\n".
    "    <DestinationZones>\n".
    "      <Zone>DMZ</Zone>\n".
    "    </DestinationZones>\n".
    "    <DestinationNetworks>\n".
    "      <Network>destination-%09d</Network>\n".
    "    </DestinationNetworks>\n".
    "  </NetworkPolicy>\n".
    "</FirewallRule>\n",
      $id, $id, $id
  ));
  print " ... done\n";
}

exit( 0 );
