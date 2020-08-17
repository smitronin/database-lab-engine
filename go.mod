module gitlab.com/postgres-ai/database-lab

go 1.13

require (
	github.com/AlekSi/pointer v1.1.0
	github.com/Azure/go-ansiterm v0.0.0-20170929234023-d6e3b3328b78 // indirect
	github.com/Microsoft/go-winio v0.4.14 // indirect
	github.com/StackExchange/wmi v0.0.0-20190523213315-cbe66965904d // indirect
	github.com/aws/aws-sdk-go v1.33.8
	github.com/containerd/containerd v1.3.4 // indirect
	github.com/docker/distribution v2.7.1+incompatible // indirect
	github.com/docker/docker v1.13.1
	github.com/docker/go-connections v0.4.0 // indirect
	github.com/docker/go-units v0.4.0 // indirect
	github.com/go-ole/go-ole v1.2.4 // indirect
	github.com/gogo/protobuf v1.3.1 // indirect
	github.com/gorilla/mux v1.7.3
	github.com/jessevdk/go-flags v1.4.1-0.20181221193153-c0795c8afcf4
	github.com/lib/pq v1.3.0
	github.com/morikuni/aec v1.0.0 // indirect
	github.com/opencontainers/go-digest v1.0.0-rc1 // indirect
	github.com/opencontainers/image-spec v1.0.1 // indirect
	github.com/pkg/errors v0.9.1
	github.com/robfig/cron/v3 v3.0.1
	github.com/rs/xid v1.2.1
	github.com/sergi/go-diff v1.1.0
	github.com/shirou/gopsutil v2.20.7+incompatible
	github.com/sirupsen/logrus v1.4.2
	github.com/stretchr/testify v1.5.1
	github.com/urfave/cli/v2 v2.1.1
	golang.org/x/crypto v0.0.0-20200604202706-70a84ac30bf9
	golang.org/x/sys v0.0.0-20200615200032-f1bc736245b1 // indirect
	golang.org/x/time v0.0.0-20200416051211-89c76fbcd5d1 // indirect
	google.golang.org/grpc v1.30.0 // indirect
	gopkg.in/yaml.v2 v2.2.7
	gotest.tools v2.2.0+incompatible // indirect
)

replace github.com/docker/docker v1.13.1 => github.com/docker/engine v17.12.0-ce-rc1.0.20200531234253-77e06fda0c94+incompatible
