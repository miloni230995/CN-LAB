# 131027- Assignment 1
# node 1-10 is through UDP
# node 2-7 is through TCP
# node 8-0 is through UDP

#Creating event scheduler
set ns [new Simulator]

#Assigning color
$ns color 1 Blue
$ns color 2 Red

#open tracefile, winfile and namfile
set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1
set namfile [open out.nam w]
$ns namtrace-all $namfile

proc finish {} \
{
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}

# setting nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

# setting links between nodes and assigning the bandwidth and delay.
$ns duplex-link $n0 $n1 2Mb 30ms DropTail
$ns duplex-link $n1 $n2 2Mb 30ms DropTail
$ns duplex-link $n0 $n3 2Mb 30ms DropTail
$ns duplex-link $n2 $n3 2Mb 30ms DropTail
$ns duplex-link $n4 $n6 2Mb 30ms DropTail
$ns duplex-link $n4 $n5 2Mb 30ms DropTail
$ns duplex-link $n5 $n6 2Mb 30ms DropTail
$ns duplex-link $n6 $n8 2Mb 30ms DropTail
$ns duplex-link $n6 $n7 2Mb 30ms DropTail
$ns duplex-link $n9 $n10 2Mb 30ms DropTail

# Node 2,4,9 is a bus, so letting lan
set lan [$ns newLan "$n2 $n4 $n9" 0.5Mb 40ms LL Queue/Droptail MAC/Csma/Cd Channel]

# orientation between the nodes
$ns duplex-link-op $n0 $n1 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n3 $n2 orient right
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n4 $n5 orient left-down
$ns duplex-link-op $n4 $n6 orient left
$ns duplex-link-op $n6 $n5 orient down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n9 $n10 orient right

#$ns queue-limit $n2 $n3 20

#Set TCP connection between 2 and 7
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 552

#assigning ftp to tcp
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#setting UDP connection between 1 and 10
set udp0 [new Agent/UDP]
$ns attach-agent $n1 $udp0
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp0 $null
$udp0 set fid_ 2

set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set packet_size_ 1000
$cbr0 set rate_ 0.01Mb
$cbr0 set random_ false

#Setting UDP between 8 and 0 
set udp1 [new Agent/UDP]
$ns attach-agent $n8 $udp1
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp1 $null
$udp1 set fid_ 3

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 0.01Mb
$cbr1 set random_ false

#scheduling the events

$ns at 0.1 "$cbr0 start"
$ns at 0.1 "$cbr1 start"
$ns at 1.0 "$ftp start"
$ns at 124.0 "$cbr0 stop"
$ns at 125.5 "$cbr1 stop"

proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}

$ns at 0.1 "plotWindow $tcp $winfile"
$ns at 125.0 "finish"
$ns run
